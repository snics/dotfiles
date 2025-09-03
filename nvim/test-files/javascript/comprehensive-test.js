// =============================================================================
// JavaScript Comprehensive Test File
// This file contains various JS features for testing LSP and Tree-sitter
// =============================================================================

// ES6+ Features, Async/Await, Classes, Modules, etc.

// Classes and Inheritance
class User {
  constructor(id, name, email, age = null) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.age = age;
    this.isActive = true;
    this.roles = ['user'];
    this.profile = null;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  // Getters and Setters
  get fullInfo() {
    return `${this.name} (${this.email}) - ${this.isActive ? 'Active' : 'Inactive'}`;
  }

  set status(value) {
    this.isActive = value;
    this.updatedAt = new Date();
  }

  // Instance methods
  activate() {
    this.isActive = true;
    this.updatedAt = new Date();
    return this;
  }

  deactivate() {
    this.isActive = false;
    this.updatedAt = new Date();
    return this;
  }

  addRole(role) {
    if (!this.roles.includes(role)) {
      this.roles.push(role);
      this.updatedAt = new Date();
    }
    return this;
  }

  removeRole(role) {
    const index = this.roles.indexOf(role);
    if (index > -1) {
      this.roles.splice(index, 1);
      this.updatedAt = new Date();
    }
    return this;
  }

  isAdmin() {
    return this.roles.includes('admin');
  }

  validate() {
    const errors = [];
    
    if (!this.name || this.name.trim() === '') {
      errors.push('Name is required');
    }
    
    if (!this.email || this.email.trim() === '') {
      errors.push('Email is required');
    } else if (!this.isValidEmail(this.email)) {
      errors.push('Invalid email format');
    }
    
    if (this.age !== null && (this.age < 0 || this.age > 150)) {
      errors.push('Age must be between 0 and 150');
    }
    
    return {
      isValid: errors.length === 0,
      errors
    };
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // Static methods
  static fromObject(obj) {
    const user = new User(obj.id, obj.name, obj.email, obj.age);
    user.isActive = obj.isActive || true;
    user.roles = obj.roles || ['user'];
    user.profile = obj.profile || null;
    user.createdAt = obj.createdAt ? new Date(obj.createdAt) : new Date();
    user.updatedAt = obj.updatedAt ? new Date(obj.updatedAt) : new Date();
    return user;
  }

  static createAdmin(name, email) {
    const user = new User(null, name, email);
    user.addRole('admin');
    return user;
  }

  // JSON serialization
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      age: this.age,
      isActive: this.isActive,
      roles: this.roles,
      profile: this.profile,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString()
    };
  }
}

// Inheritance
class AdminUser extends User {
  constructor(id, name, email, permissions = []) {
    super(id, name, email);
    this.permissions = permissions;
    this.roles = ['admin', 'user'];
  }

  addPermission(permission) {
    if (!this.permissions.includes(permission)) {
      this.permissions.push(permission);
      this.updatedAt = new Date();
    }
    return this;
  }

  hasPermission(permission) {
    return this.permissions.includes(permission);
  }

  canManageUsers() {
    return this.hasPermission('manage_users');
  }

  canAccessAdminPanel() {
    return this.hasPermission('admin_panel');
  }
}

// Profile class
class UserProfile {
  constructor(bio = '', avatar = null) {
    this.bio = bio;
    this.avatar = avatar;
    this.preferences = new Map();
    this.socialLinks = [];
  }

  setPreference(key, value) {
    this.preferences.set(key, value);
  }

  getPreference(key) {
    return this.preferences.get(key);
  }

  addSocialLink(platform, url, verified = false) {
    this.socialLinks.push({
      platform,
      url,
      verified,
      addedAt: new Date()
    });
  }

  getVerifiedLinks() {
    return this.socialLinks.filter(link => link.verified);
  }
}

// Repository Pattern
class UserRepository {
  constructor() {
    this.users = new Map();
    this.nextId = 1;
  }

  async save(user) {
    if (!user.id) {
      user.id = this.nextId++;
    }
    
    const validation = user.validate();
    if (!validation.isValid) {
      throw new Error(`Validation failed: ${validation.errors.join(', ')}`);
    }
    
    user.updatedAt = new Date();
    this.users.set(user.id, user);
    return user;
  }

  async findById(id) {
    return this.users.get(id) || null;
  }

  async findAll() {
    return Array.from(this.users.values());
  }

  async findBy(criteria) {
    const users = await this.findAll();
    return users.filter(user => {
      for (const [key, value] of Object.entries(criteria)) {
        if (user[key] !== value) {
          return false;
        }
      }
      return true;
    });
  }

  async delete(id) {
    return this.users.delete(id);
  }

  async count() {
    return this.users.size;
  }
}

// Service Layer
class UserService {
  constructor(repository) {
    this.repository = repository;
  }

  async createUser(name, email, age = null) {
    const user = new User(null, name, email, age);
    return await this.repository.save(user);
  }

  async getUserById(id) {
    const user = await this.repository.findById(id);
    if (!user) {
      throw new Error(`User with id ${id} not found`);
    }
    return user;
  }

  async updateUser(id, updates) {
    const user = await this.getUserById(id);
    
    Object.keys(updates).forEach(key => {
      if (user.hasOwnProperty(key) && key !== 'id' && key !== 'createdAt') {
        user[key] = updates[key];
      }
    });
    
    return await this.repository.save(user);
  }

  async deleteUser(id) {
    const exists = await this.repository.findById(id);
    if (!exists) {
      throw new Error(`User with id ${id} not found`);
    }
    return await this.repository.delete(id);
  }

  async listUsers(limit = 10, offset = 0) {
    const allUsers = await this.repository.findAll();
    return allUsers.slice(offset, offset + limit);
  }

  async searchUsers(query) {
    const allUsers = await this.repository.findAll();
    const lowerQuery = query.toLowerCase();
    
    return allUsers.filter(user => 
      user.name.toLowerCase().includes(lowerQuery) ||
      user.email.toLowerCase().includes(lowerQuery)
    );
  }
}

// API Client
class ApiClient {
  constructor(baseUrl, apiKey = null) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
    this.defaultHeaders = {
      'Content-Type': 'application/json'
    };
    
    if (this.apiKey) {
      this.defaultHeaders['Authorization'] = `Bearer ${this.apiKey}`;
    }
  }

  async makeRequest(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const config = {
      headers: { ...this.defaultHeaders, ...options.headers },
      ...options
    };

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return {
        data,
        status: response.status,
        headers: response.headers
      };
    } catch (error) {
      throw new Error(`API request failed: ${error.message}`);
    }
  }

  async get(endpoint) {
    return this.makeRequest(endpoint, { method: 'GET' });
  }

  async post(endpoint, data) {
    return this.makeRequest(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  async put(endpoint, data) {
    return this.makeRequest(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  }

  async delete(endpoint) {
    return this.makeRequest(endpoint, { method: 'DELETE' });
  }
}

// Utility Functions
const Utils = {
  // Array utilities
  chunk(array, size) {
    const chunks = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  },

  unique(array) {
    return [...new Set(array)];
  },

  groupBy(array, key) {
    return array.reduce((groups, item) => {
      const group = item[key];
      groups[group] = groups[group] || [];
      groups[group].push(item);
      return groups;
    }, {});
  },

  sortBy(array, key, direction = 'asc') {
    return array.sort((a, b) => {
      const aVal = a[key];
      const bVal = b[key];
      
      if (direction === 'desc') {
        return bVal > aVal ? 1 : -1;
      }
      return aVal > bVal ? 1 : -1;
    });
  },

  // Object utilities
  deepClone(obj) {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Date) return new Date(obj.getTime());
    if (obj instanceof Array) return obj.map(item => this.deepClone(item));
    if (typeof obj === 'object') {
      const cloned = {};
      Object.keys(obj).forEach(key => {
        cloned[key] = this.deepClone(obj[key]);
      });
      return cloned;
    }
  },

  merge(target, ...sources) {
    sources.forEach(source => {
      Object.keys(source).forEach(key => {
        if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
          target[key] = this.merge(target[key] || {}, source[key]);
        } else {
          target[key] = source[key];
        }
      });
    });
    return target;
  },

  // String utilities
  capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  },

  camelCase(str) {
    return str.replace(/-([a-z])/g, (match, letter) => letter.toUpperCase());
  },

  kebabCase(str) {
    return str.replace(/([A-Z])/g, '-$1').toLowerCase();
  },

  // Validation utilities
  isEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  isUrl(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  },

  isNumeric(value) {
    return !isNaN(parseFloat(value)) && isFinite(value);
  },

  // Date utilities
  formatDate(date, format = 'YYYY-MM-DD') {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    
    return format
      .replace('YYYY', year)
      .replace('MM', month)
      .replace('DD', day);
  },

  addDays(date, days) {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  },

  // Async utilities
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  },

  retry(fn, maxAttempts = 3, delay = 1000) {
    return new Promise(async (resolve, reject) => {
      let lastError;
      
      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          const result = await fn();
          resolve(result);
          return;
        } catch (error) {
          lastError = error;
          if (attempt < maxAttempts) {
            await this.delay(delay * attempt);
          }
        }
      }
      
      reject(lastError);
    });
  },

  // Functional programming utilities
  pipe(...fns) {
    return (value) => fns.reduce((acc, fn) => fn(acc), value);
  },

  compose(...fns) {
    return (value) => fns.reduceRight((acc, fn) => fn(acc), value);
  },

  curry(fn) {
    return function curried(...args) {
      if (args.length >= fn.length) {
        return fn.apply(this, args);
      } else {
        return function(...nextArgs) {
          return curried.apply(this, args.concat(nextArgs));
        };
      }
    };
  },

  memoize(fn) {
    const cache = new Map();
    return function(...args) {
      const key = JSON.stringify(args);
      if (cache.has(key)) {
        return cache.get(key);
      }
      const result = fn.apply(this, args);
      cache.set(key, result);
      return result;
    };
  }
};

// Event System
class EventEmitter {
  constructor() {
    this.events = new Map();
  }

  on(event, listener) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }
    this.events.get(event).push(listener);
    return this;
  }

  off(event, listener) {
    if (!this.events.has(event)) return this;
    
    const listeners = this.events.get(event);
    const index = listeners.indexOf(listener);
    if (index > -1) {
      listeners.splice(index, 1);
    }
    return this;
  }

  emit(event, ...args) {
    if (!this.events.has(event)) return false;
    
    const listeners = this.events.get(event);
    listeners.forEach(listener => {
      try {
        listener.apply(this, args);
      } catch (error) {
        console.error(`Error in event listener for ${event}:`, error);
      }
    });
    return true;
  }

  once(event, listener) {
    const onceWrapper = (...args) => {
      this.off(event, onceWrapper);
      listener.apply(this, args);
    };
    return this.on(event, onceWrapper);
  }
}

// State Management
class StateManager {
  constructor(initialState = {}) {
    this.state = { ...initialState };
    this.listeners = [];
    this.middleware = [];
  }

  getState() {
    return { ...this.state };
  }

  setState(newState) {
    const prevState = { ...this.state };
    this.state = { ...this.state, ...newState };
    
    // Run middleware
    this.middleware.forEach(middleware => {
      middleware(prevState, this.state);
    });
    
    // Notify listeners
    this.listeners.forEach(listener => {
      listener(this.state, prevState);
    });
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  addMiddleware(middleware) {
    this.middleware.push(middleware);
  }
}

// Cache System
class Cache {
  constructor(maxSize = 100, ttl = 300000) { // 5 minutes default TTL
    this.cache = new Map();
    this.maxSize = maxSize;
    this.ttl = ttl;
  }

  set(key, value, customTtl = null) {
    const expiry = Date.now() + (customTtl || this.ttl);
    
    // Remove oldest entries if cache is full
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    this.cache.set(key, { value, expiry });
  }

  get(key) {
    const item = this.cache.get(key);
    
    if (!item) {
      return null;
    }
    
    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }

  has(key) {
    return this.get(key) !== null;
  }

  delete(key) {
    return this.cache.delete(key);
  }

  clear() {
    this.cache.clear();
  }

  size() {
    return this.cache.size;
  }
}

// Database-like operations
class Database {
  constructor() {
    this.tables = new Map();
  }

  createTable(name, schema) {
    this.tables.set(name, {
      schema,
      data: [],
      indexes: new Map()
    });
  }

  insert(tableName, record) {
    const table = this.tables.get(tableName);
    if (!table) {
      throw new Error(`Table ${tableName} does not exist`);
    }

    const id = Date.now() + Math.random();
    const newRecord = { id, ...record, createdAt: new Date() };
    table.data.push(newRecord);
    
    return newRecord;
  }

  select(tableName, where = {}) {
    const table = this.tables.get(tableName);
    if (!table) {
      throw new Error(`Table ${tableName} does not exist`);
    }

    if (Object.keys(where).length === 0) {
      return [...table.data];
    }

    return table.data.filter(record => {
      return Object.keys(where).every(key => record[key] === where[key]);
    });
  }

  update(tableName, where, updates) {
    const table = this.tables.get(tableName);
    if (!table) {
      throw new Error(`Table ${tableName} does not exist`);
    }

    let updatedCount = 0;
    table.data.forEach(record => {
      const matches = Object.keys(where).every(key => record[key] === where[key]);
      if (matches) {
        Object.assign(record, updates, { updatedAt: new Date() });
        updatedCount++;
      }
    });

    return updatedCount;
  }

  delete(tableName, where) {
    const table = this.tables.get(tableName);
    if (!table) {
      throw new Error(`Table ${tableName} does not exist`);
    }

    const initialLength = table.data.length;
    table.data = table.data.filter(record => {
      return !Object.keys(where).every(key => record[key] === where[key]);
    });

    return initialLength - table.data.length;
  }
}

// Main application
class Application {
  constructor() {
    this.userRepository = new UserRepository();
    this.userService = new UserService(this.userRepository);
    this.apiClient = new ApiClient('https://api.example.com');
    this.eventEmitter = new EventEmitter();
    this.stateManager = new StateManager({ users: [], loading: false });
    this.cache = new Cache(50, 300000); // 5 minutes
    this.database = new Database();
    
    this.setupEventHandlers();
    this.initializeDatabase();
  }

  setupEventHandlers() {
    this.eventEmitter.on('userCreated', (user) => {
      console.log(`User created: ${user.name}`);
      this.stateManager.setState({ 
        users: [...this.stateManager.getState().users, user] 
      });
    });

    this.eventEmitter.on('userUpdated', (user) => {
      console.log(`User updated: ${user.name}`);
      const currentUsers = this.stateManager.getState().users;
      const updatedUsers = currentUsers.map(u => u.id === user.id ? user : u);
      this.stateManager.setState({ users: updatedUsers });
    });

    this.eventEmitter.on('userDeleted', (userId) => {
      console.log(`User deleted: ${userId}`);
      const currentUsers = this.stateManager.getState().users;
      const filteredUsers = currentUsers.filter(u => u.id !== userId);
      this.stateManager.setState({ users: filteredUsers });
    });
  }

  initializeDatabase() {
    this.database.createTable('users', {
      id: 'number',
      name: 'string',
      email: 'string',
      age: 'number',
      isActive: 'boolean',
      roles: 'array',
      createdAt: 'date',
      updatedAt: 'date'
    });
  }

  async run() {
    try {
      console.log('Starting application...');
      
      // Create some test users
      const user1 = await this.userService.createUser('John Doe', 'john@example.com', 30);
      const user2 = await this.userService.createUser('Jane Smith', 'jane@example.com', 25);
      const admin = AdminUser.createAdmin('Admin User', 'admin@example.com');
      
      this.eventEmitter.emit('userCreated', user1);
      this.eventEmitter.emit('userCreated', user2);
      this.eventEmitter.emit('userCreated', admin);

      // Update a user
      const updatedUser = await this.userService.updateUser(user1.id, { 
        name: 'John Updated',
        age: 31 
      });
      this.eventEmitter.emit('userUpdated', updatedUser);

      // Search users
      const searchResults = await this.userService.searchUsers('John');
      console.log('Search results:', searchResults);

      // Test utility functions
      const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      const chunks = Utils.chunk(numbers, 3);
      console.log('Chunks:', chunks);

      const uniqueNumbers = Utils.unique([1, 2, 2, 3, 3, 3, 4]);
      console.log('Unique numbers:', uniqueNumbers);

      // Test caching
      this.cache.set('test-key', 'test-value');
      console.log('Cached value:', this.cache.get('test-key'));

      // Test database operations
      const dbUser = this.database.insert('users', {
        name: 'DB User',
        email: 'db@example.com',
        age: 28,
        isActive: true,
        roles: ['user']
      });
      console.log('Database user:', dbUser);

      const dbUsers = this.database.select('users');
      console.log('All database users:', dbUsers);

      // Test async operations
      await this.testAsyncOperations();

      console.log('Application completed successfully');
      
    } catch (error) {
      console.error('Application error:', error);
    }
  }

  async testAsyncOperations() {
    console.log('Testing async operations...');
    
    // Test delay
    console.log('Starting delay test...');
    await Utils.delay(1000);
    console.log('Delay test completed');

    // Test retry mechanism
    let attemptCount = 0;
    const result = await Utils.retry(async () => {
      attemptCount++;
      if (attemptCount < 3) {
        throw new Error('Simulated failure');
      }
      return 'Success after retries';
    }, 3, 500);
    
    console.log('Retry result:', result);

    // Test functional programming
    const add = (a, b) => a + b;
    const multiply = (a, b) => a * b;
    const curriedAdd = Utils.curry(add);
    const addFive = curriedAdd(5);
    console.log('Curried add result:', addFive(3));

    const pipe = Utils.pipe(
      (x) => x * 2,
      (x) => x + 1,
      (x) => x * 3
    );
    console.log('Pipe result:', pipe(5)); // ((5 * 2) + 1) * 3 = 33

    // Test memoization
    const expensiveFunction = (n) => {
      console.log(`Computing for ${n}`);
      return n * n;
    };
    
    const memoizedFunction = Utils.memoize(expensiveFunction);
    console.log('Memoized result 1:', memoizedFunction(5));
    console.log('Memoized result 2:', memoizedFunction(5)); // Should not log "Computing"
  }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    User,
    AdminUser,
    UserProfile,
    UserRepository,
    UserService,
    ApiClient,
    Utils,
    EventEmitter,
    StateManager,
    Cache,
    Database,
    Application
  };
}

// Run application if this is the main file
if (typeof window === 'undefined' && require.main === module) {
  const app = new Application();
  app.run().catch(console.error);
}
