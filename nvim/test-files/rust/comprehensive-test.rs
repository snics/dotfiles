// =============================================================================
// Rust Comprehensive Test File
// This file contains various Rust features for testing LSP and Tree-sitter
// =============================================================================

use std::collections::{HashMap, HashSet, VecDeque};
use std::fmt::{self, Display, Formatter};
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};
use std::path::Path;
use std::sync::{Arc, Mutex, RwLock};
use std::thread;
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use std::error::Error;
use std::result::Result as StdResult;

// Type aliases
type UserId = u32;
type Timestamp = u64;
type Result<T> = StdResult<T, Box<dyn Error>>;

// Enums
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
enum UserRole {
    Admin,
    User,
    Moderator,
    Guest,
}

impl Display for UserRole {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            UserRole::Admin => write!(f, "admin"),
            UserRole::User => write!(f, "user"),
            UserRole::Moderator => write!(f, "moderator"),
            UserRole::Guest => write!(f, "guest"),
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
enum UserStatus {
    Active,
    Inactive,
    Suspended,
    Pending,
}

impl Display for UserStatus {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            UserStatus::Active => write!(f, "active"),
            UserStatus::Inactive => write!(f, "inactive"),
            UserStatus::Suspended => write!(f, "suspended"),
            UserStatus::Pending => write!(f, "pending"),
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
enum ValidationError {
    EmptyField(String),
    InvalidEmail(String),
    InvalidAge(u32),
    DuplicateEmail(String),
    InvalidRole(String),
}

impl Display for ValidationError {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            ValidationError::EmptyField(field) => write!(f, "Field '{}' cannot be empty", field),
            ValidationError::InvalidEmail(email) => write!(f, "Invalid email format: {}", email),
            ValidationError::InvalidAge(age) => write!(f, "Invalid age: {}", age),
            ValidationError::DuplicateEmail(email) => write!(f, "Email already exists: {}", email),
            ValidationError::InvalidRole(role) => write!(f, "Invalid role: {}", role),
        }
    }
}

impl Error for ValidationError {}

// Structs
#[derive(Debug, Clone, PartialEq)]
struct User {
    id: UserId,
    name: String,
    email: String,
    age: Option<u32>,
    status: UserStatus,
    roles: HashSet<UserRole>,
    profile: Option<UserProfile>,
    created_at: Timestamp,
    updated_at: Timestamp,
}

#[derive(Debug, Clone, PartialEq)]
struct UserProfile {
    avatar: Option<String>,
    bio: String,
    preferences: HashMap<String, String>,
    social_links: Vec<SocialLink>,
}

#[derive(Debug, Clone, PartialEq)]
struct SocialLink {
    platform: String,
    url: String,
    verified: bool,
}

#[derive(Debug, Clone, PartialEq)]
struct PaginationInfo {
    page: u32,
    limit: u32,
    total: u32,
    total_pages: u32,
}

#[derive(Debug, Clone, PartialEq)]
struct ApiResponse<T> {
    data: T,
    status: u16,
    message: String,
    timestamp: Timestamp,
    pagination: Option<PaginationInfo>,
}

// Traits
trait Repository<T, ID> {
    fn find_by_id(&self, id: ID) -> Result<Option<T>>;
    fn find_all(&self) -> Result<Vec<T>>;
    fn save(&mut self, entity: T) -> Result<T>;
    fn update(&mut self, id: ID, entity: T) -> Result<T>;
    fn delete(&mut self, id: ID) -> Result<bool>;
    fn find_by_criteria(&self, criteria: &HashMap<String, String>) -> Result<Vec<T>>;
}

trait Service<T, ID> {
    fn create(&self, data: CreateUserData) -> Result<T>;
    fn get(&self, id: ID) -> Result<T>;
    fn update(&self, id: ID, data: UpdateUserData) -> Result<T>;
    fn delete(&self, id: ID) -> Result<bool>;
    fn list(&self, page: u32, limit: u32) -> Result<Vec<T>>;
    fn search(&self, query: &str) -> Result<Vec<T>>;
}

#[derive(Debug, Clone, PartialEq)]
struct CreateUserData {
    name: String,
    email: String,
    age: Option<u32>,
    roles: Vec<UserRole>,
}

#[derive(Debug, Clone, PartialEq)]
struct UpdateUserData {
    name: Option<String>,
    email: Option<String>,
    age: Option<u32>,
    status: Option<UserStatus>,
    roles: Option<Vec<UserRole>>,
}

// Implementation
impl User {
    fn new(id: UserId, name: String, email: String) -> Self {
        let now = current_timestamp();
        Self {
            id,
            name,
            email,
            age: None,
            status: UserStatus::Active,
            roles: HashSet::from([UserRole::User]),
            profile: None,
            created_at: now,
            updated_at: now,
        }
    }

    fn with_age(mut self, age: u32) -> Self {
        self.age = Some(age);
        self.updated_at = current_timestamp();
        self
    }

    fn with_roles(mut self, roles: Vec<UserRole>) -> Self {
        self.roles = roles.into_iter().collect();
        self.updated_at = current_timestamp();
        self
    }

    fn with_profile(mut self, profile: UserProfile) -> Self {
        self.profile = Some(profile);
        self.updated_at = current_timestamp();
        self
    }

    fn update_status(&mut self, status: UserStatus) {
        self.status = status;
        self.updated_at = current_timestamp();
    }

    fn add_role(&mut self, role: UserRole) {
        self.roles.insert(role);
        self.updated_at = current_timestamp();
    }

    fn remove_role(&mut self, role: &UserRole) {
        self.roles.remove(role);
        self.updated_at = current_timestamp();
    }

    fn is_admin(&self) -> bool {
        self.roles.contains(&UserRole::Admin)
    }

    fn is_active(&self) -> bool {
        self.status == UserStatus::Active
    }

    fn validate(&self) -> Result<()> {
        if self.name.trim().is_empty() {
            return Err(ValidationError::EmptyField("name".to_string()).into());
        }

        if self.email.trim().is_empty() {
            return Err(ValidationError::EmptyField("email".to_string()).into());
        }

        if !is_valid_email(&self.email) {
            return Err(ValidationError::InvalidEmail(self.email.clone()).into());
        }

        if let Some(age) = self.age {
            if age > 150 {
                return Err(ValidationError::InvalidAge(age).into());
            }
        }

        Ok(())
    }
}

impl UserProfile {
    fn new(bio: String) -> Self {
        Self {
            avatar: None,
            bio,
            preferences: HashMap::new(),
            social_links: Vec::new(),
        }
    }

    fn with_avatar(mut self, avatar: String) -> Self {
        self.avatar = Some(avatar);
        self
    }

    fn add_preference(&mut self, key: String, value: String) {
        self.preferences.insert(key, value);
    }

    fn add_social_link(&mut self, platform: String, url: String, verified: bool) {
        self.social_links.push(SocialLink {
            platform,
            url,
            verified,
        });
    }
}

// Repository implementation
struct InMemoryUserRepository {
    users: HashMap<UserId, User>,
    next_id: UserId,
    email_index: HashMap<String, UserId>,
}

impl InMemoryUserRepository {
    fn new() -> Self {
        Self {
            users: HashMap::new(),
            next_id: 1,
            email_index: HashMap::new(),
        }
    }

    fn generate_id(&mut self) -> UserId {
        let id = self.next_id;
        self.next_id += 1;
        id
    }
}

impl Repository<User, UserId> for InMemoryUserRepository {
    fn find_by_id(&self, id: UserId) -> Result<Option<User>> {
        Ok(self.users.get(&id).cloned())
    }

    fn find_all(&self) -> Result<Vec<User>> {
        Ok(self.users.values().cloned().collect())
    }

    fn save(&mut self, mut user: User) -> Result<User> {
        user.validate()?;

        // Check for duplicate email
        if self.email_index.contains_key(&user.email) {
            return Err(ValidationError::DuplicateEmail(user.email).into());
        }

        let id = self.generate_id();
        user.id = id;
        user.created_at = current_timestamp();
        user.updated_at = current_timestamp();

        self.email_index.insert(user.email.clone(), id);
        self.users.insert(id, user.clone());

        Ok(user)
    }

    fn update(&mut self, id: UserId, mut user: User) -> Result<User> {
        user.validate()?;

        if let Some(existing_user) = self.users.get(&id) {
            // Check for duplicate email (excluding current user)
            if user.email != existing_user.email && self.email_index.contains_key(&user.email) {
                return Err(ValidationError::DuplicateEmail(user.email).into());
            }

            // Update email index if email changed
            if user.email != existing_user.email {
                self.email_index.remove(&existing_user.email);
                self.email_index.insert(user.email.clone(), id);
            }

            user.id = id;
            user.created_at = existing_user.created_at;
            user.updated_at = current_timestamp();

            self.users.insert(id, user.clone());
            Ok(user)
        } else {
            Err(format!("User with id {} not found", id).into())
        }
    }

    fn delete(&mut self, id: UserId) -> Result<bool> {
        if let Some(user) = self.users.remove(&id) {
            self.email_index.remove(&user.email);
            Ok(true)
        } else {
            Ok(false)
        }
    }

    fn find_by_criteria(&self, criteria: &HashMap<String, String>) -> Result<Vec<User>> {
        let mut results = Vec::new();

        for user in self.users.values() {
            let mut matches = true;

            for (key, value) in criteria {
                match key.as_str() {
                    "name" => {
                        if !user.name.to_lowercase().contains(&value.to_lowercase()) {
                            matches = false;
                        }
                    }
                    "email" => {
                        if !user.email.to_lowercase().contains(&value.to_lowercase()) {
                            matches = false;
                        }
                    }
                    "status" => {
                        if user.status.to_string() != *value {
                            matches = false;
                        }
                    }
                    _ => {}
                }

                if !matches {
                    break;
                }
            }

            if matches {
                results.push(user.clone());
            }
        }

        Ok(results)
    }
}

// Service implementation
struct UserService {
    repository: Arc<RwLock<InMemoryUserRepository>>,
}

impl UserService {
    fn new() -> Self {
        Self {
            repository: Arc::new(RwLock::new(InMemoryUserRepository::new())),
        }
    }
}

impl Service<User, UserId> for UserService {
    fn create(&self, data: CreateUserData) -> Result<User> {
        let user = User::new(0, data.name, data.email)
            .with_age(data.age.unwrap_or(0))
            .with_roles(data.roles);

        let mut repo = self.repository.write().unwrap();
        repo.save(user)
    }

    fn get(&self, id: UserId) -> Result<User> {
        let repo = self.repository.read().unwrap();
        repo.find_by_id(id)?
            .ok_or_else(|| format!("User with id {} not found", id).into())
    }

    fn update(&self, id: UserId, data: UpdateUserData) -> Result<User> {
        let mut repo = self.repository.write().unwrap();
        let mut user = repo.find_by_id(id)?
            .ok_or_else(|| format!("User with id {} not found", id).into())?;

        if let Some(name) = data.name {
            user.name = name;
        }

        if let Some(email) = data.email {
            user.email = email;
        }

        if let Some(age) = data.age {
            user.age = Some(age);
        }

        if let Some(status) = data.status {
            user.update_status(status);
        }

        if let Some(roles) = data.roles {
            user.roles = roles.into_iter().collect();
        }

        repo.update(id, user)
    }

    fn delete(&self, id: UserId) -> Result<bool> {
        let mut repo = self.repository.write().unwrap();
        repo.delete(id)
    }

    fn list(&self, page: u32, limit: u32) -> Result<Vec<User>> {
        let repo = self.repository.read().unwrap();
        let all_users = repo.find_all()?;

        let start = (page * limit) as usize;
        let end = ((page + 1) * limit) as usize;

        let users = if start >= all_users.len() {
            Vec::new()
        } else if end >= all_users.len() {
            all_users[start..].to_vec()
        } else {
            all_users[start..end].to_vec()
        };

        Ok(users)
    }

    fn search(&self, query: &str) -> Result<Vec<User>> {
        let repo = self.repository.read().unwrap();
        let mut criteria = HashMap::new();
        criteria.insert("name".to_string(), query.to_string());
        repo.find_by_criteria(&criteria)
    }
}

// Utility functions
fn current_timestamp() -> Timestamp {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
}

fn is_valid_email(email: &str) -> bool {
    email.contains('@') && email.contains('.') && !email.starts_with('@') && !email.ends_with('@')
}

fn validate_email(email: &str) -> Result<()> {
    if !is_valid_email(email) {
        return Err(ValidationError::InvalidEmail(email.to_string()).into());
    }
    Ok(())
}

fn validate_age(age: u32) -> Result<()> {
    if age > 150 {
        return Err(ValidationError::InvalidAge(age).into());
    }
    Ok(())
}

// Generic utility functions
fn map<T, U, F>(items: Vec<T>, f: F) -> Vec<U>
where
    F: Fn(T) -> U,
{
    items.into_iter().map(f).collect()
}

fn filter<T, F>(items: Vec<T>, f: F) -> Vec<T>
where
    F: Fn(&T) -> bool,
{
    items.into_iter().filter(f).collect()
}

fn reduce<T, F>(items: Vec<T>, initial: T, f: F) -> T
where
    F: Fn(T, T) -> T,
{
    items.into_iter().fold(initial, f)
}

fn find<T, F>(items: &[T], f: F) -> Option<&T>
where
    F: Fn(&T) -> bool,
{
    items.iter().find(|item| f(item))
}

fn group_by<T, K, F>(items: Vec<T>, key_fn: F) -> HashMap<K, Vec<T>>
where
    K: std::hash::Hash + Eq,
    F: Fn(&T) -> K,
{
    let mut groups: HashMap<K, Vec<T>> = HashMap::new();
    for item in items {
        let key = key_fn(&item);
        groups.entry(key).or_insert_with(Vec::new).push(item);
    }
    groups
}

// Async/await simulation with threads
fn process_users_concurrently<F>(users: Vec<User>, processor: F) -> Vec<Result<String>>
where
    F: Fn(User) -> Result<String> + Send + Sync + 'static,
{
    let processor = Arc::new(processor);
    let mut handles = Vec::new();

    for user in users {
        let processor = Arc::clone(&processor);
        let handle = thread::spawn(move || processor(user));
        handles.push(handle);
    }

    handles
        .into_iter()
        .map(|handle| handle.join().unwrap())
        .collect()
}

// File operations
fn read_file_lines<P: AsRef<Path>>(path: P) -> Result<Vec<String>> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let lines: Result<Vec<String>, io::Error> = reader.lines().collect();
    Ok(lines?)
}

fn write_file<P: AsRef<Path>>(path: P, content: &str) -> Result<()> {
    let mut file = File::create(path)?;
    file.write_all(content.as_bytes())?;
    Ok(())
}

// Mathematical operations
fn calculate_distance(x1: f64, y1: f64, x2: f64, y2: f64) -> f64 {
    let dx = x2 - x1;
    let dy = y2 - y1;
    (dx * dx + dy * dy).sqrt()
}

fn calculate_average(numbers: &[f64]) -> f64 {
    if numbers.is_empty() {
        return 0.0;
    }
    numbers.iter().sum::<f64>() / numbers.len() as f64
}

fn calculate_median(mut numbers: Vec<f64>) -> f64 {
    if numbers.is_empty() {
        return 0.0;
    }

    numbers.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let n = numbers.len();

    if n % 2 == 0 {
        (numbers[n / 2 - 1] + numbers[n / 2]) / 2.0
    } else {
        numbers[n / 2]
    }
}

fn calculate_standard_deviation(numbers: &[f64]) -> f64 {
    if numbers.is_empty() {
        return 0.0;
    }

    let mean = calculate_average(numbers);
    let variance = numbers
        .iter()
        .map(|&x| (x - mean).powi(2))
        .sum::<f64>()
        / numbers.len() as f64;

    variance.sqrt()
}

// Iterator chains and functional programming
fn process_user_data(users: Vec<User>) -> Vec<String> {
    users
        .into_iter()
        .filter(|user| user.is_active())
        .filter(|user| user.age.unwrap_or(0) >= 18)
        .map(|user| format!("{} ({})", user.name, user.email))
        .collect()
}

fn get_admin_emails(users: &[User]) -> Vec<String> {
    users
        .iter()
        .filter(|user| user.is_admin())
        .map(|user| user.email.clone())
        .collect()
}

fn group_users_by_role(users: Vec<User>) -> HashMap<UserRole, Vec<User>> {
    let mut groups: HashMap<UserRole, Vec<User>> = HashMap::new();

    for user in users {
        for role in &user.roles {
            groups.entry(role.clone()).or_insert_with(Vec::new).push(user.clone());
        }
    }

    groups
}

// Error handling examples
fn risky_operation() -> Result<String> {
    // Simulate a risky operation that might fail
    if rand::random::<f64>() < 0.5 {
        Err("Random failure occurred".into())
    } else {
        Ok("Operation successful".to_string())
    }
}

fn handle_errors_example() {
    match risky_operation() {
        Ok(result) => println!("Success: {}", result),
        Err(e) => println!("Error: {}", e),
    }
}

// Pattern matching examples
fn match_user_status(status: &UserStatus) -> &'static str {
    match status {
        UserStatus::Active => "User is active and can perform all operations",
        UserStatus::Inactive => "User is inactive and has limited access",
        UserStatus::Suspended => "User is suspended and cannot access the system",
        UserStatus::Pending => "User account is pending approval",
    }
}

fn match_user_role(role: &UserRole) -> u8 {
    match role {
        UserRole::Admin => 4,
        UserRole::Moderator => 3,
        UserRole::User => 2,
        UserRole::Guest => 1,
    }
}

// Main function
fn main() -> Result<()> {
    println!("Starting Rust comprehensive test application");

    // Initialize service
    let service = UserService::new();

    // Create test users
    let user1 = service.create(CreateUserData {
        name: "John Doe".to_string(),
        email: "john@example.com".to_string(),
        age: Some(30),
        roles: vec![UserRole::User],
    })?;

    let user2 = service.create(CreateUserData {
        name: "Jane Smith".to_string(),
        email: "jane@example.com".to_string(),
        age: Some(25),
        roles: vec![UserRole::Admin, UserRole::User],
    })?;

    println!("Created users: {} and {}", user1.name, user2.name);

    // Update user
    let updated_user = service.update(user1.id, UpdateUserData {
        name: Some("John Updated".to_string()),
        age: Some(31),
        status: Some(UserStatus::Active),
        roles: Some(vec![UserRole::Admin, UserRole::User]),
        email: None,
    })?;

    println!("Updated user: {}", updated_user.name);

    // List users
    let users = service.list(0, 10)?;
    println!("Total users: {}", users.len());

    // Search users
    let search_results = service.search("John")?;
    println!("Search results for 'John': {}", search_results.len());

    // Test utility functions
    let numbers = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    println!("Average: {:.2}", calculate_average(&numbers));
    println!("Median: {:.2}", calculate_median(numbers.clone()));
    println!("Standard deviation: {:.2}", calculate_standard_deviation(&numbers));

    // Test functional programming
    let processed_data = process_user_data(users.clone());
    println!("Processed user data: {:?}", processed_data);

    let admin_emails = get_admin_emails(&users);
    println!("Admin emails: {:?}", admin_emails);

    let grouped_users = group_users_by_role(users);
    for (role, role_users) in grouped_users {
        println!("Users with role {}: {}", role, role_users.len());
    }

    // Test error handling
    handle_errors_example();

    // Test pattern matching
    for user in &users {
        println!("{}: {}", user.name, match_user_status(&user.status));
        for role in &user.roles {
            println!("  Role {}: priority {}", role, match_user_role(role));
        }
    }

    // Test concurrent processing
    let processing_results = process_users_concurrently(users.clone(), |user| {
        thread::sleep(Duration::from_millis(100));
        Ok(format!("Processed user: {}", user.name))
    });

    for result in processing_results {
        match result {
            Ok(message) => println!("{}", message),
            Err(e) => println!("Processing error: {}", e),
        }
    }

    // Test file operations
    let test_content = "Hello, Rust!\nThis is a test file.\n";
    write_file("test_output.txt", test_content)?;
    println!("Written test file");

    let lines = read_file_lines("test_output.txt")?;
    println!("Read {} lines from file", lines.len());

    // Clean up
    std::fs::remove_file("test_output.txt")?;
    println!("Cleaned up test file");

    println!("Application completed successfully");
    Ok(())
}

// Tests
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new(1, "Test User".to_string(), "test@example.com".to_string());
        assert_eq!(user.name, "Test User");
        assert_eq!(user.email, "test@example.com");
        assert_eq!(user.status, UserStatus::Active);
        assert!(user.roles.contains(&UserRole::User));
    }

    #[test]
    fn test_user_validation() {
        let valid_user = User::new(1, "Valid User".to_string(), "valid@example.com".to_string());
        assert!(valid_user.validate().is_ok());

        let invalid_user = User::new(1, "".to_string(), "invalid-email".to_string());
        assert!(invalid_user.validate().is_err());
    }

    #[test]
    fn test_email_validation() {
        assert!(is_valid_email("test@example.com"));
        assert!(!is_valid_email("invalid-email"));
        assert!(!is_valid_email("@example.com"));
        assert!(!is_valid_email("test@"));
    }

    #[test]
    fn test_mathematical_functions() {
        let numbers = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        assert_eq!(calculate_average(&numbers), 3.0);
        assert_eq!(calculate_median(numbers), 3.0);
    }

    #[test]
    fn test_utility_functions() {
        let numbers = vec![1, 2, 3, 4, 5];
        let doubled = map(numbers, |x| x * 2);
        assert_eq!(doubled, vec![2, 4, 6, 8, 10]);

        let evens = filter(vec![1, 2, 3, 4, 5], |&x| x % 2 == 0);
        assert_eq!(evens, vec![2, 4]);

        let sum = reduce(vec![1, 2, 3, 4, 5], 0, |acc, x| acc + x);
        assert_eq!(sum, 15);
    }
}
