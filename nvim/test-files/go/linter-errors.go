//go:build linux || ignore || Old || (format && ignore) || should || use || ignore
// +build linux ignore Old format,ignore should use ignore

package main

// =============================================================================
// Go Test File with Intentional Errors
// Tests for golangci-lint, gofumpt, goimports, golines
// =============================================================================

import (
	"context"
	"errors"
	"fmt" // Error: Unused import
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
	// Imported but not used initially
)

// Error: Missing package comment
// Error: Imports not properly grouped (stdlib should be separate from third-party)

// Error: Exported type without comment
type User struct {
	Id       int    // Error: Should be ID, not Id
	Name     string `json:"name"`
	Email    string `json:"email"`
	IsActive bool   `json:"is_active"`
	// Error: Inconsistent struct tag formatting
	Password string    `json:"password,omitempty"`
	Created  time.Time `json:"created_at" db:"created_at"`
}

// Error: Exported function without comment
func ProcessUser(u *User) error {
	// Error: Parameter could be non-pointer since it's not modified
	if u == nil {
		return errors.New("User is nil") // Error: Error strings should not be capitalized
	}
	return nil
}

// Error: Function too long (exceeds cognitive complexity)
func ComplexFunction(input string) (string, error) {
	// Error: Too many nested blocks
	if input != "" {
		if len(input) > 10 {
			if strings.Contains(input, "test") {
				if strings.HasPrefix(input, "prefix") {
					if strings.HasSuffix(input, "suffix") {
						return input, nil
					} else { // Error: Unnecessary else after return
						return "", errors.New("Invalid suffix")
					}
				} else {
					return "", errors.New("Invalid prefix")
				}
			} else {
				return "", errors.New("Does not contain test")
			}
		} else {
			return "", errors.New("Too short")
		}
	} else {
		return "", errors.New("Empty input")
	}
}

// Error: Unused function
func unusedFunction() {
	fmt.Println("This is never called")
}

// Error: Global variable without comment
var GlobalVar = "global" // Error: Should avoid global variables

// Error: Init function (often discouraged)
func init() {
	fmt.Println("Init function")
}

// Error: Empty interface (interface{} instead of any for Go 1.18+)
func AcceptAnything(v interface{}) {
	// Error: Type assertion without checking
	str := v.(string) // Could panic
	fmt.Println(str)
}

// Error: Inefficient string concatenation in loop
func InefficientConcat(items []string) string {
	result := ""
	for _, item := range items {
		result = result + item // Should use strings.Builder
	}
	return result
}

// Error: Not checking error
func IgnoreError() {
	_ = http.ListenAndServe(":8080", nil) // Error explicitly ignored
	http.ListenAndServe(":8081", nil)     // Error implicitly ignored
}

// Error: Inefficient slice initialization
func InefficientSlice() []int {
	var s []int
	for i := 0; i < 100; i++ {
		s = append(s, i) // Should pre-allocate with make
	}
	return s
}

// Error: defer in loop
func DeferInLoop(files []string) {
	for _, file := range files {
		f, _ := os.Open(file) // Error: Not checking error
		defer f.Close()       // Error: defer in loop
	}
}

// Error: Empty critical section
func EmptyMutex() {
	var mu sync.Mutex
	mu.Lock()
	// Nothing here
	mu.Unlock()
}

// Error: Comparing error with string
func CompareError(err error) bool {
	return err.Error() == "some error" // Should use errors.Is
}

// Error: Type switch with single case
func SingleCaseSwitch(v interface{}) {
	switch v.(type) {
	case string:
		fmt.Println("string")
	}
	// Should just use type assertion
}

// Error: Magic numbers
func MagicNumbers(value int) bool {
	return value > 42 // What does 42 mean?
}

const MaxRetries = 3 // Good: named constant

// Error: Inconsistent receiver names
func (u *User) Method1()    {}
func (user *User) Method2() {} // Should use consistent receiver name

// Error: Method on non-pointer receiver that modifies
func (u User) SetName(name string) {
	u.Name = name // Doesn't actually modify the original
}

// Error: Naked return
func NakedReturn() (result int, err error) {
	result = 42
	return // Naked return
}

// Error: Unnecessary type conversion
func UnnecessaryConversion() {
	var i int = 42
	j := int(i) // Unnecessary conversion
	fmt.Println(j)
}

// Error: Invalid build tag format

// Error: Unused struct fields
type UnusedFields struct {
	Used   string
	Unused string // Never accessed
}

// Error: JSON tag on unexported field
type InvalidTags struct {
	exported   string `json:"exported"`   // Won't work: field not exported
	Unexported string `json:"unexported"` // OK: field is exported
}

// Error: Println in production code
func DebugPrint(msg string) {
	fmt.Println(msg) // Should use proper logging
}

// Error: TODO without assignee
// TODO: Fix this later  // Should be TODO(username):
// FIXME: This is broken  // Should have assignee

// Error: Long line that should be broken up
func VeryLongLine() {
	fmt.Printf("This is an extremely long line that exceeds the typical line length limit that gofumpt and other formatters would want to break up into multiple lines for better readability")
}

// Error: If-return pattern
func IfReturn(condition bool) bool {
	if condition == true { // Error: Comparing bool to true
		return true
	}
	return false
	// Should be: return condition
}

// Error: Empty if body
func EmptyIf(value int) {
	if value > 0 {
		// Nothing here
	}
}

// Error: Yoda conditions
func YodaCondition(value string) bool {
	return "expected" == value // Yoda condition
}

// Error: Inefficient map check
func MapCheck(m map[string]int, key string) {
	_, ok := m[key]
	if ok == true { // Should be: if ok
		fmt.Println("exists")
	}
}

// Error: panic in library code
func LibraryFunction() {
	panic("this should return an error instead")
}

// Error: Single-case select
func SingleSelect(ch chan int) {
	select {
	case <-ch:
		fmt.Println("received")
	}
	// Should just use <-ch directly
}

// Error: Sprintf for simple concatenation
func SprintfConcat(name string) string {
	return fmt.Sprintf("Hello %s", name) // Could use simple concatenation
}

// Error: Sleep in test-like code
func SleepInCode() {
	time.Sleep(1 * time.Second) // Should avoid sleep in production
}

// Error: Mutex passed by value
func PassMutexByValue(mu sync.Mutex) { // Should pass by pointer
	mu.Lock()
	defer mu.Unlock()
}

// Error: Context not first parameter
func WrongContextPosition(name string, ctx context.Context) { // ctx should be first
	// ...
}

// Error: Creating error with fmt.Errorf without format
func SimpleError() error {
	return fmt.Errorf("simple error") // Should use errors.New
}

// Error: Redundant type in composite literal
func RedundantType() {
	users := []User{
		User{Name: "Alice"}, // Redundant User type
		User{Name: "Bob"},
	}
	fmt.Println(users)
}

// Error: Switch with no cases
func EmptySwitch(value int) {
	switch value {
	}
}

// Error: Unreachable code
func Unreachable() {
	return
	fmt.Println("unreachable") // Unreachable code
}

// Error: Self-assignment
func SelfAssignment() {
	x := 5
	x = x // Self-assignment
}

// Error: Duplicate imports (would be error if actually duplicated)

// Error: Comment format issues
//This comment has no space after slashes
/*This is a C-style comment which is valid but discouraged*/
//  This comment has extra spaces

// Error: Variable shadowing
func Shadowing() {
	doSomething := func() error { return nil }
	doSomethingElse := func() error { return nil }

	err := doSomething()
	if err != nil {
		err := doSomethingElse() // Shadows outer err
		fmt.Println(err)
	}
}

// Error: Missing error check in range
func RangeError() {
	m := map[string]int{"a": 1}
	for k, _ := range m { // Should use _ for value if not needed
		fmt.Println(k)
	}
}

// Error: Inconsistent spacing
func InconsistentSpacing() {
	x := 5               // No spaces
	y := 10              // Inconsistent
	z := 15              // Correct
	fmt.Println(x, y, z) // Use variables
}

// Error: Empty else block
func EmptyElse(value int) {
	if value > 0 {
		fmt.Println("positive")
	} else {
		// Empty else
	}
}

// Error: File doesn't end with newline
func main() {
	fmt.Println("Main function")
}
