# Test Files for LSP and Tree-sitter

This directory contains comprehensive test files for various programming languages to test LSP (Language Server Protocol) and Tree-sitter functionality.

## Directory Structure

```
test-files/
├── go/                          # Go language tests
│   └── comprehensive-test.go    # Complete Go features test
├── rust/                        # Rust language tests
│   └── comprehensive-test.rs    # Complete Rust features test
├── javascript/                  # JavaScript tests
│   ├── comprehensive-test.js    # Complete JS features test
│   ├── simple-test.js          # Basic JS test
│   └── textobjects-test.js     # Tree-sitter textobjects test
├── typescript/                  # TypeScript tests
│   └── comprehensive-test.ts    # Complete TS features test
├── tsx/                         # React TSX tests
│   └── comprehensive-test.tsx   # Complete React TSX test
└── yaml/                        # YAML/K8s tests
    ├── kubernetes-comprehensive-test.yaml  # Complete K8s test
    ├── docker-compose-test.yml             # Docker Compose test
    ├── github-actions-test.yml             # GitHub Actions test
    └── simple-pod.yaml                     # Basic K8s pod test
```

## Language Features Covered

### Go (`go/comprehensive-test.go`)
- **Basic Types**: Structs, interfaces, type aliases
- **Generics**: Generic functions and types (Go 1.18+)
- **Error Handling**: Custom error types, error wrapping
- **Concurrency**: Goroutines, channels, sync primitives
- **Reflection**: Type reflection, struct field manipulation
- **File Operations**: Reading/writing files, JSON handling
- **Mathematical Operations**: Distance calculation, statistics
- **Repository Pattern**: Interface-based repository implementation
- **Service Layer**: Business logic separation
- **HTTP Handlers**: REST API implementation
- **Testing**: Unit tests with table-driven tests

### Rust (`rust/comprehensive-test.rs`)
- **Ownership & Borrowing**: Move semantics, references
- **Enums & Pattern Matching**: Complex enums, match expressions
- **Traits**: Generic traits, trait bounds
- **Error Handling**: Result types, custom error types
- **Collections**: HashMap, HashSet, Vec, VecDeque
- **Concurrency**: Threads, Arc, Mutex, RwLock
- **Functional Programming**: Closures, iterators, map/filter/reduce
- **Async/Await**: Future simulation with threads
- **File Operations**: Reading/writing files, error handling
- **Mathematical Operations**: Statistics, distance calculations
- **Repository Pattern**: Generic repository implementation
- **Service Layer**: Business logic with error handling
- **Testing**: Unit tests, integration tests

### JavaScript (`javascript/comprehensive-test.js`)
- **ES6+ Features**: Classes, arrow functions, destructuring
- **Async/Await**: Promises, async functions
- **Modules**: CommonJS exports, ES6 modules
- **Inheritance**: Class inheritance, method overriding
- **Functional Programming**: Higher-order functions, currying
- **Event System**: Custom event emitter implementation
- **State Management**: Simple state manager
- **Caching**: LRU cache implementation
- **Database Operations**: In-memory database simulation
- **Utility Functions**: Array manipulation, object utilities
- **Error Handling**: Try-catch, custom error types
- **Testing**: Mock functions, async testing

### TypeScript (`typescript/comprehensive-test.ts`)
- **Type System**: Interfaces, types, generics
- **Advanced Types**: Union types, intersection types, mapped types
- **Decorators**: Method decorators, class decorators
- **Modules**: ES6 modules, namespace declarations
- **Enums**: String enums, numeric enums
- **Utility Types**: Partial, Required, Pick, Omit
- **Conditional Types**: Type-level conditionals
- **Template Literal Types**: String template types
- **Async/Await**: Promise handling, error types
- **Repository Pattern**: Generic repository with type safety
- **Service Layer**: Type-safe business logic
- **API Client**: Generic API client with type safety
- **Error Handling**: Custom error classes with type safety

### React TSX (`tsx/comprehensive-test.tsx`)
- **React Hooks**: useState, useEffect, useCallback, useMemo
- **Custom Hooks**: useLocalStorage, useDebounce, useAsync
- **Context API**: User context, provider pattern
- **State Management**: useReducer, complex state
- **Component Patterns**: HOC, render props, compound components
- **TypeScript Integration**: Props types, state types
- **Event Handling**: Form handling, async operations
- **Performance**: memo, useMemo, useCallback optimization
- **Error Boundaries**: Error handling components
- **Lazy Loading**: React.lazy, Suspense
- **Testing**: Component testing patterns
- **Accessibility**: ARIA attributes, semantic HTML

### YAML/Kubernetes (`yaml/`)
- **Kubernetes Resources**: Pods, Deployments, Services, ConfigMaps
- **Advanced K8s**: StatefulSets, DaemonSets, Jobs, CronJobs
- **Networking**: Ingress, NetworkPolicy, Service types
- **Security**: RBAC, ServiceAccounts, Secrets
- **Storage**: PersistentVolumes, PersistentVolumeClaims
- **Monitoring**: ServiceMonitor, HorizontalPodAutoscaler
- **Custom Resources**: CRDs, custom resource definitions
- **Docker Compose**: Multi-service applications, networks, volumes
- **GitHub Actions**: CI/CD pipelines, matrix builds, environments
- **Complex Configurations**: Multi-environment setups

## Tree-sitter Textobjects

These files are designed to test Tree-sitter textobjects functionality:

### Function Textobjects
- `af` - Around function
- `if` - Inside function
- `]m` - Next function start
- `[m` - Previous function start

### Class Textobjects
- `ac` - Around class
- `ic` - Inside class
- `]c` - Next class start
- `[c` - Previous class start

### Parameter Textobjects
- `aa` - Around argument
- `ia` - Inside argument
- `<leader>a` - Swap parameter with next
- `<leader>A` - Swap parameter with previous

### Control Flow Textobjects
- `ai` - Around conditional
- `ii` - Inside conditional
- `al` - Around loop
- `il` - Inside loop

### Block Textobjects
- `ab` - Around block
- `ib` - Inside block
- `aC` - Around call
- `iC` - Inside call

### YAML Textobjects
- `as` - Around assignment (key: value)
- `is` - Inside assignment (value only)
- `ak` - Assignment key (left side)
- `av` - Assignment value (right side)

## Usage

These test files can be used to:

1. **Test LSP Features**: Syntax highlighting, autocomplete, error detection
2. **Test Tree-sitter**: Textobject navigation, syntax parsing
3. **Test Language Servers**: Go, Rust, TypeScript, JavaScript language servers
4. **Test Neovim Plugins**: Comment.nvim, which-key, flash navigation
5. **Development**: Reference implementations, code examples

## File Naming Convention

- `comprehensive-test.*` - Complete language feature coverage
- `simple-*` - Basic examples for quick testing
- `textobjects-*` - Specific Tree-sitter textobject testing
- `*-test.*` - Language-specific test files

## Contributing

When adding new test files:

1. Follow the existing naming convention
2. Include comprehensive language features
3. Add comments explaining complex constructs
4. Test Tree-sitter textobjects where applicable
5. Update this README with new features covered
