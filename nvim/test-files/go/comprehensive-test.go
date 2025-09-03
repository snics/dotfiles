// =============================================================================
// Go Comprehensive Test File
// This file contains various Go features for testing LSP and Tree-sitter
// =============================================================================

package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math"
	"net/http"
	"os"
	"reflect"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Basic types and structs
type User struct {
	ID       int       `json:"id" db:"id"`
	Name     string    `json:"name" db:"name"`
	Email    string    `json:"email" db:"email"`
	Age      *int      `json:"age,omitempty" db:"age"`
	IsActive bool      `json:"is_active" db:"is_active"`
	Roles    []string  `json:"roles" db:"roles"`
	Profile  *Profile  `json:"profile,omitempty" db:"profile"`
	Created  time.Time `json:"created_at" db:"created_at"`
	Updated  time.Time `json:"updated_at" db:"updated_at"`
}

type Profile struct {
	Avatar      string            `json:"avatar,omitempty" db:"avatar"`
	Bio         string            `json:"bio" db:"bio"`
	Preferences map[string]string `json:"preferences" db:"preferences"`
	SocialLinks []SocialLink      `json:"social_links" db:"social_links"`
}

type SocialLink struct {
	Platform string `json:"platform" db:"platform"`
	URL      string `json:"url" db:"url"`
	Verified bool   `json:"verified" db:"verified"`
}

// Interfaces
type Repository interface {
	FindByID(ctx context.Context, id int) (*User, error)
	FindAll(ctx context.Context) ([]*User, error)
	Save(ctx context.Context, user *User) error
	Update(ctx context.Context, user *User) error
	Delete(ctx context.Context, id int) error
	FindBy(ctx context.Context, criteria map[string]interface{}) ([]*User, error)
}

type Service interface {
	CreateUser(ctx context.Context, name, email string) (*User, error)
	GetUser(ctx context.Context, id int) (*User, error)
	UpdateUser(ctx context.Context, id int, updates map[string]interface{}) (*User, error)
	DeleteUser(ctx context.Context, id int) error
	ListUsers(ctx context.Context, limit, offset int) ([]*User, error)
	SearchUsers(ctx context.Context, query string) ([]*User, error)
}

// Generic types (Go 1.18+)
type Response[T any] struct {
	Data    T         `json:"data"`
	Status  int       `json:"status"`
	Message string    `json:"message"`
	Time    time.Time `json:"timestamp"`
}

type PaginatedResponse[T any] struct {
	Response[T]
	Pagination PaginationInfo `json:"pagination,omitempty"`
}

type PaginationInfo struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

// Enums using constants
const (
	StatusPending   = "pending"
	StatusApproved  = "approved"
	StatusRejected  = "rejected"
	StatusCancelled = "cancelled"
)

const (
	RoleAdmin     = "admin"
	RoleUser      = "user"
	RoleModerator = "moderator"
	RoleGuest     = "guest"
)

// Custom error types
type AppError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
}

func (e *AppError) Error() string {
	return fmt.Sprintf("error %d: %s", e.Code, e.Message)
}

type ValidationError struct {
	Field   string      `json:"field"`
	Value   interface{} `json:"value"`
	Message string      `json:"message"`
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("validation error for field '%s': %s", e.Field, e.Message)
}

type NotFoundError struct {
	Resource string `json:"resource"`
	ID       string `json:"id"`
}

func (e *NotFoundError) Error() string {
	return fmt.Sprintf("%s with id %s not found", e.Resource, e.ID)
}

// TODO: Implement persistence layer with database
// HACK: Using in-memory storage for now
// Repository implementation
type InMemoryRepository struct {
	users  map[int]*User
	nextID int
	mutex  sync.RWMutex
}

func NewInMemoryRepository() *InMemoryRepository {
	return &InMemoryRepository{
		users:  make(map[int]*User),
		nextID: 1,
	}
}

func (r *InMemoryRepository) FindByID(ctx context.Context, id int) (*User, error) {
	r.mutex.RLock()
	defer r.mutex.RUnlock()

	user, exists := r.users[id]
	if !exists {
		return nil, &NotFoundError{Resource: "User", ID: strconv.Itoa(id)}
	}
	return user, nil
}

func (r *InMemoryRepository) FindAll(ctx context.Context) ([]*User, error) {
	r.mutex.RLock()
	defer r.mutex.RUnlock()

	users := make([]*User, 0, len(r.users))
	for _, user := range r.users {
		users = append(users, user)
	}
	return users, nil
}

func (r *InMemoryRepository) Save(ctx context.Context, user *User) error {
	r.mutex.Lock()
	defer r.mutex.Unlock()

	user.ID = r.nextID
	user.Created = time.Now()
	user.Updated = time.Now()
	r.users[r.nextID] = user
	r.nextID++
	return nil
}

func (r *InMemoryRepository) Update(ctx context.Context, user *User) error {
	r.mutex.Lock()
	defer r.mutex.Unlock()

	if _, exists := r.users[user.ID]; !exists {
		return &NotFoundError{Resource: "User", ID: strconv.Itoa(user.ID)}
	}

	user.Updated = time.Now()
	r.users[user.ID] = user
	return nil
}

func (r *InMemoryRepository) Delete(ctx context.Context, id int) error {
	r.mutex.Lock()
	defer r.mutex.Unlock()

	if _, exists := r.users[id]; !exists {
		return &NotFoundError{Resource: "User", ID: strconv.Itoa(id)}
	}

	delete(r.users, id)
	return nil
}

func (r *InMemoryRepository) FindBy(ctx context.Context, criteria map[string]interface{}) ([]*User, error) {
	r.mutex.RLock()
	defer r.mutex.RUnlock()

	var results []*User
	for _, user := range r.users {
		if r.matchesCriteria(user, criteria) {
			results = append(results, user)
		}
	}
	return results, nil
}

func (r *InMemoryRepository) matchesCriteria(user *User, criteria map[string]interface{}) bool {
	for field, value := range criteria {
		switch field {
		case "name":
			if name, ok := value.(string); ok && !strings.Contains(strings.ToLower(user.Name), strings.ToLower(name)) {
				return false
			}
		case "email":
			if email, ok := value.(string); ok && !strings.Contains(strings.ToLower(user.Email), strings.ToLower(email)) {
				return false
			}
		case "is_active":
			if active, ok := value.(bool); ok && user.IsActive != active {
				return false
			}
		}
	}
	return true
}

// Service implementation
type UserService struct {
	repo Repository
}

func NewUserService(repo Repository) *UserService {
	return &UserService{repo: repo}
}

func (s *UserService) CreateUser(ctx context.Context, name, email string) (*User, error) {
	// Validation
	if strings.TrimSpace(name) == "" {
		return nil, &ValidationError{Field: "name", Value: name, Message: "name is required"}
	}
	if strings.TrimSpace(email) == "" {
		return nil, &ValidationError{Field: "email", Value: email, Message: "email is required"}
	}
	if !strings.Contains(email, "@") {
		return nil, &ValidationError{Field: "email", Value: email, Message: "invalid email format"}
	}

	user := &User{
		Name:     strings.TrimSpace(name),
		Email:    strings.TrimSpace(email),
		IsActive: true,
		Roles:    []string{RoleUser},
	}

	if err := s.repo.Save(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to save user: %w", err)
	}

	return user, nil
}

func (s *UserService) GetUser(ctx context.Context, id int) (*User, error) {
	user, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	return user, nil
}

func (s *UserService) UpdateUser(ctx context.Context, id int, updates map[string]interface{}) (*User, error) {
	user, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user for update: %w", err)
	}

	// Apply updates
	for field, value := range updates {
		switch field {
		case "name":
			if name, ok := value.(string); ok {
				if strings.TrimSpace(name) == "" {
					return nil, &ValidationError{Field: "name", Value: name, Message: "name cannot be empty"}
				}
				user.Name = strings.TrimSpace(name)
			}
		case "email":
			if email, ok := value.(string); ok {
				if strings.TrimSpace(email) == "" {
					return nil, &ValidationError{Field: "email", Value: email, Message: "email cannot be empty"}
				}
				if !strings.Contains(email, "@") {
					return nil, &ValidationError{Field: "email", Value: email, Message: "invalid email format"}
				}
				user.Email = strings.TrimSpace(email)
			}
		case "is_active":
			if active, ok := value.(bool); ok {
				user.IsActive = active
			}
		case "roles":
			if roles, ok := value.([]string); ok {
				user.Roles = roles
			}
		}
	}

	if err := s.repo.Update(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return user, nil
}

func (s *UserService) DeleteUser(ctx context.Context, id int) error {
	if err := s.repo.Delete(ctx, id); err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}
	return nil
}

func (s *UserService) ListUsers(ctx context.Context, limit, offset int) ([]*User, error) {
	users, err := s.repo.FindAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to list users: %w", err)
	}

	// Simple pagination
	start := offset
	end := offset + limit
	if start >= len(users) {
		return []*User{}, nil
	}
	if end > len(users) {
		end = len(users)
	}

	return users[start:end], nil
}

func (s *UserService) SearchUsers(ctx context.Context, query string) ([]*User, error) {
	criteria := map[string]interface{}{
		"name": query,
	}

	users, err := s.repo.FindBy(ctx, criteria)
	if err != nil {
		return nil, fmt.Errorf("failed to search users: %w", err)
	}

	return users, nil
}

// HTTP handlers
type HTTPHandler struct {
	service Service
}

func NewHTTPHandler(service Service) *HTTPHandler {
	return &HTTPHandler{service: service}
}

func (h *HTTPHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Name  string `json:"name"`
		Email string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	user, err := h.service.CreateUser(r.Context(), req.Name, req.Email)
	if err != nil {
		h.handleError(w, err)
		return
	}

	h.writeJSON(w, http.StatusCreated, Response[*User]{
		Data:    user,
		Status:  http.StatusCreated,
		Message: "User created successfully",
		Time:    time.Now(),
	})
}

func (h *HTTPHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	user, err := h.service.GetUser(r.Context(), id)
	if err != nil {
		h.handleError(w, err)
		return
	}

	h.writeJSON(w, http.StatusOK, Response[*User]{
		Data:    user,
		Status:  http.StatusOK,
		Message: "User retrieved successfully",
		Time:    time.Now(),
	})
}

func (h *HTTPHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	limit := 10
	offset := 0

	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	if offsetStr != "" {
		if o, err := strconv.Atoi(offsetStr); err == nil && o >= 0 {
			offset = o
		}
	}

	users, err := h.service.ListUsers(r.Context(), limit, offset)
	if err != nil {
		h.handleError(w, err)
		return
	}

	h.writeJSON(w, http.StatusOK, PaginatedResponse[[]*User]{
		Response: Response[[]*User]{
			Data:    users,
			Status:  http.StatusOK,
			Message: "Users retrieved successfully",
			Time:    time.Now(),
		},
		Pagination: PaginationInfo{
			Page:  offset/limit + 1,
			Limit: limit,
			Total: len(users),
		},
	})
}

func (h *HTTPHandler) handleError(w http.ResponseWriter, err error) {
	switch e := err.(type) {
	case *ValidationError:
		http.Error(w, e.Error(), http.StatusBadRequest)
	case *NotFoundError:
		http.Error(w, e.Error(), http.StatusNotFound)
	case *AppError:
		http.Error(w, e.Error(), e.Code)
	default:
		log.Printf("Internal server error: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
}

func (h *HTTPHandler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// Utility functions
func ValidateEmail(email string) bool {
	return strings.Contains(email, "@") && strings.Contains(email, ".")
}

func SanitizeString(s string) string {
	return strings.TrimSpace(strings.ToLower(s))
}

func ContainsString(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func RemoveString(slice []string, item string) []string {
	var result []string
	for _, s := range slice {
		if s != item {
			result = append(result, s)
		}
	}
	return result
}

// Generic utility functions
func Map[T, U any](slice []T, fn func(T) U) []U {
	result := make([]U, len(slice))
	for i, item := range slice {
		result[i] = fn(item)
	}
	return result
}

func Filter[T any](slice []T, fn func(T) bool) []T {
	var result []T
	for _, item := range slice {
		if fn(item) {
			result = append(result, item)
		}
	}
	return result
}

func Reduce[T, U any](slice []T, initial U, fn func(U, T) U) U {
	result := initial
	for _, item := range slice {
		result = fn(result, item)
	}
	return result
}

// Concurrent processing
func ProcessUsersConcurrently(users []*User, fn func(*User) error) []error {
	var wg sync.WaitGroup
	errors := make([]error, len(users))

	for i, user := range users {
		wg.Add(1)
		go func(index int, u *User) {
			defer wg.Done()
			errors[index] = fn(u)
		}(i, user)
	}

	wg.Wait()
	return errors
}

// Context with timeout
func ProcessWithTimeout(ctx context.Context, timeout time.Duration, fn func() error) error {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	done := make(chan error, 1)
	go func() {
		done <- fn()
	}()

	select {
	case err := <-done:
		return err
	case <-ctx.Done():
		return ctx.Err()
	}
}

// Reflection utilities
func GetStructFields(v interface{}) []string {
	t := reflect.TypeOf(v)
	if t.Kind() == reflect.Ptr {
		t = t.Elem()
	}

	var fields []string
	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)
		fields = append(fields, field.Name)
	}
	return fields
}

func SetStructField(v interface{}, fieldName string, value interface{}) error {
	rv := reflect.ValueOf(v)
	if rv.Kind() != reflect.Ptr || rv.Elem().Kind() != reflect.Struct {
		return errors.New("v must be a pointer to a struct")
	}

	rv = rv.Elem()
	field := rv.FieldByName(fieldName)
	if !field.IsValid() {
		return fmt.Errorf("field %s not found", fieldName)
	}

	if !field.CanSet() {
		return fmt.Errorf("field %s cannot be set", fieldName)
	}

	field.Set(reflect.ValueOf(value))
	return nil
}

// File operations
func ReadFile(filename string) ([]byte, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open file: %w", err)
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}

	return data, nil
}

func WriteFile(filename string, data []byte) error {
	file, err := os.Create(filename)
	if err != nil {
		return fmt.Errorf("failed to create file: %w", err)
	}
	defer file.Close()

	_, err = file.Write(data)
	if err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

// Mathematical operations
func CalculateDistance(x1, y1, x2, y2 float64) float64 {
	dx := x2 - x1
	dy := y2 - y1
	return math.Sqrt(dx*dx + dy*dy)
}

func CalculateAverage(numbers []float64) float64 {
	if len(numbers) == 0 {
		return 0
	}

	sum := 0.0
	for _, num := range numbers {
		sum += num
	}
	return sum / float64(len(numbers))
}

func CalculateMedian(numbers []float64) float64 {
	if len(numbers) == 0 {
		return 0
	}

	sorted := make([]float64, len(numbers))
	copy(sorted, numbers)
	sort.Float64s(sorted)

	n := len(sorted)
	if n%2 == 0 {
		return (sorted[n/2-1] + sorted[n/2]) / 2
	}
	return sorted[n/2]
}

// Main function
func main() {
	// Initialize repository and service
	repo := NewInMemoryRepository()
	service := NewUserService(repo)
	handler := NewHTTPHandler(service)

	// Create some test users
	ctx := context.Background()

	user1, err := service.CreateUser(ctx, "John Doe", "john@example.com")
	if err != nil {
		log.Fatalf("Failed to create user1: %v", err)
	}

	user2, err := service.CreateUser(ctx, "Jane Smith", "jane@example.com")
	if err != nil {
		log.Fatalf("Failed to create user2: %v", err)
	}

	// Update user1
	updatedUser, err := service.UpdateUser(ctx, user1.ID, map[string]interface{}{
		"name":  "John Updated",
		"roles": []string{RoleAdmin, RoleUser},
	})
	if err != nil {
		log.Fatalf("Failed to update user: %v", err)
	}

	// List users
	users, err := service.ListUsers(ctx, 10, 0)
	if err != nil {
		log.Fatalf("Failed to list users: %v", err)
	}

	fmt.Printf("Created %d users\n", len(users))
	for _, user := range users {
		fmt.Printf("User: %s (%s) - Active: %t, Roles: %v\n",
			user.Name, user.Email, user.IsActive, user.Roles)
	}

	// Test concurrent processing
	processErrors := ProcessUsersConcurrently(users, func(u *User) error {
		fmt.Printf("Processing user: %s\n", u.Name)
		time.Sleep(100 * time.Millisecond)
		return nil
	})

	for i, err := range processErrors {
		if err != nil {
			fmt.Printf("Error processing user %d: %v\n", i, err)
		}
	}

	// Test utility functions
	numbers := []float64{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	fmt.Printf("Average: %.2f\n", CalculateAverage(numbers))
	fmt.Printf("Median: %.2f\n", CalculateMedian(numbers))

	// Test generic functions
	names := Map(users, func(u *User) string { return u.Name })
	fmt.Printf("User names: %v\n", names)

	activeUsers := Filter(users, func(u *User) bool { return u.IsActive })
	fmt.Printf("Active users: %d\n", len(activeUsers))

	// Test reflection
	fields := GetStructFields(user1)
	fmt.Printf("User struct fields: %v\n", fields)

	// Test context with timeout
	err = ProcessWithTimeout(ctx, 2*time.Second, func() error {
		time.Sleep(1 * time.Second)
		fmt.Println("Task completed within timeout")
		return nil
	})
	if err != nil {
		fmt.Printf("Task failed: %v\n", err)
	}

	fmt.Println("Application completed successfully")
}
