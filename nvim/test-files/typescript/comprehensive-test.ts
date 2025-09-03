// =============================================================================
// TypeScript Comprehensive Test File
// This file contains various TS features for testing LSP and Tree-sitter
// =============================================================================

// Basic types and interfaces
interface User {
  id: number;
  name: string;
  email: string;
  age?: number;
  isActive: boolean;
  roles: string[];
  profile: UserProfile;
  createdAt: Date;
  updatedAt?: Date;
}

interface UserProfile {
  avatar?: string;
  bio: string;
  preferences: UserPreferences;
  socialLinks: SocialLink[];
}

interface UserPreferences {
  theme: 'light' | 'dark';
  language: string;
  notifications: NotificationSettings;
}

interface NotificationSettings {
  email: boolean;
  push: boolean;
  sms: boolean;
}

interface SocialLink {
  platform: string;
  url: string;
  verified: boolean;
}

// Generic types
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
  timestamp: Date;
  pagination?: PaginationInfo;
}

interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

// Union types and type guards
type Status = 'pending' | 'approved' | 'rejected' | 'cancelled';
type UserRole = 'admin' | 'user' | 'moderator' | 'guest';
type EventType = 'click' | 'hover' | 'focus' | 'blur';

// Type guards
function isUser(obj: any): obj is User {
  return obj && typeof obj.id === 'number' && typeof obj.name === 'string';
}

function isApiResponse<T>(obj: any): obj is ApiResponse<T> {
  return obj && typeof obj.status === 'number' && obj.data !== undefined;
}

// Enums
enum HttpStatus {
  OK = 200,
  CREATED = 201,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  INTERNAL_SERVER_ERROR = 500,
}

enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4,
}

// Classes with inheritance and generics
abstract class BaseEntity {
  protected id: number;
  protected createdAt: Date;
  protected updatedAt: Date;

  constructor(id: number) {
    this.id = id;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  abstract validate(): boolean;
  
  protected updateTimestamp(): void {
    this.updatedAt = new Date();
  }

  public getId(): number {
    return this.id;
  }

  public getCreatedAt(): Date {
    return this.createdAt;
  }

  public getUpdatedAt(): Date {
    return this.updatedAt;
  }
}

class UserEntity extends BaseEntity {
  private name: string;
  private email: string;
  private isActive: boolean;
  private roles: UserRole[];

  constructor(id: number, name: string, email: string) {
    super(id);
    this.name = name;
    this.email = email;
    this.isActive = true;
    this.roles = ['user'];
  }

  validate(): boolean {
    return this.name.length > 0 && this.email.includes('@');
  }

  public getName(): string {
    return this.name;
  }

  public getEmail(): string {
    return this.email;
  }

  public isUserActive(): boolean {
    return this.isActive;
  }

  public getRoles(): UserRole[] {
    return [...this.roles];
  }

  public addRole(role: UserRole): void {
    if (!this.roles.includes(role)) {
      this.roles.push(role);
      this.updateTimestamp();
    }
  }

  public removeRole(role: UserRole): void {
    const index = this.roles.indexOf(role);
    if (index > -1) {
      this.roles.splice(index, 1);
      this.updateTimestamp();
    }
  }

  public activate(): void {
    this.isActive = true;
    this.updateTimestamp();
  }

  public deactivate(): void {
    this.isActive = false;
    this.updateTimestamp();
  }
}

// Generic repository pattern
interface Repository<T extends BaseEntity> {
  findById(id: number): Promise<T | null>;
  findAll(): Promise<T[]>;
  save(entity: T): Promise<T>;
  update(entity: T): Promise<T>;
  delete(id: number): Promise<boolean>;
  findBy(criteria: Partial<T>): Promise<T[]>;
}

class UserRepository implements Repository<UserEntity> {
  private users: Map<number, UserEntity> = new Map();
  private nextId: number = 1;

  async findById(id: number): Promise<UserEntity | null> {
    return this.users.get(id) || null;
  }

  async findAll(): Promise<UserEntity[]> {
    return Array.from(this.users.values());
  }

  async save(user: UserEntity): Promise<UserEntity> {
    const id = this.nextId++;
    const newUser = new UserEntity(id, user.getName(), user.getEmail());
    this.users.set(id, newUser);
    return newUser;
  }

  async update(user: UserEntity): Promise<UserEntity> {
    this.users.set(user.getId(), user);
    return user;
  }

  async delete(id: number): Promise<boolean> {
    return this.users.delete(id);
  }

  async findBy(criteria: Partial<UserEntity>): Promise<UserEntity[]> {
    return Array.from(this.users.values()).filter(user => {
      // Simple filtering logic - in real app would be more sophisticated
      return true; // Placeholder
    });
  }
}

// Service layer with dependency injection
interface UserService {
  createUser(name: string, email: string): Promise<UserEntity>;
  getUserById(id: number): Promise<UserEntity | null>;
  updateUser(id: number, updates: Partial<User>): Promise<UserEntity>;
  deleteUser(id: number): Promise<boolean>;
  getAllUsers(): Promise<UserEntity[]>;
  activateUser(id: number): Promise<UserEntity>;
  deactivateUser(id: number): Promise<UserEntity>;
}

class UserServiceImpl implements UserService {
  constructor(private userRepository: Repository<UserEntity>) {}

  async createUser(name: string, email: string): Promise<UserEntity> {
    const user = new UserEntity(0, name, email);
    if (!user.validate()) {
      throw new Error('Invalid user data');
    }
    return await this.userRepository.save(user);
  }

  async getUserById(id: number): Promise<UserEntity | null> {
    return await this.userRepository.findById(id);
  }

  async updateUser(id: number, updates: Partial<User>): Promise<UserEntity> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new Error('User not found');
    }
    // Update logic would go here
    return await this.userRepository.update(user);
  }

  async deleteUser(id: number): Promise<boolean> {
    return await this.userRepository.delete(id);
  }

  async getAllUsers(): Promise<UserEntity[]> {
    return await this.userRepository.findAll();
  }

  async activateUser(id: number): Promise<UserEntity> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new Error('User not found');
    }
    user.activate();
    return await this.userRepository.update(user);
  }

  async deactivateUser(id: number): Promise<UserEntity> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new Error('User not found');
    }
    user.deactivate();
    return await this.userRepository.update(user);
  }
}

// TODO: Refactor diese Utility-Klasse in separate Module
// FIXME: Type guards funktionieren nicht mit strictNullChecks
// Utility functions with advanced TypeScript features
class TypeUtils {
  // Conditional types
  static isString(value: unknown): value is string {
    return typeof value === 'string';
  }

  static isNumber(value: unknown): value is number {
    return typeof value === 'number' && !isNaN(value);
  }

  static isArray<T>(value: unknown): value is T[] {
    return Array.isArray(value);
  }

  // Mapped types
  static makeOptional<T>(obj: T): Partial<T> {
    return obj;
  }

  static makeRequired<T>(obj: Partial<T>): Required<T> {
    return obj as Required<T>;
  }

  // Template literal types
  static createApiEndpoint<T extends string>(resource: T): `api/v1/${T}` {
    return `api/v1/${resource}` as const;
  }

  // Utility type examples
  static pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
    const result = {} as Pick<T, K>;
    keys.forEach(key => {
      result[key] = obj[key];
    });
    return result;
  }

  static omit<T, K extends keyof T>(obj: T, keys: K[]): Omit<T, K> {
    const result = { ...obj };
    keys.forEach(key => {
      delete result[key];
    });
    return result;
  }
}

// Async/await patterns
class ApiClient {
  private baseUrl: string;
  private apiKey: string;

  constructor(baseUrl: string, apiKey: string) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  private async makeRequest<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseUrl}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.apiKey}`,
      ...options.headers,
    };

    try {
      const response = await fetch(url, { ...options, headers });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return {
        data,
        status: response.status,
        message: 'Success',
        timestamp: new Date(),
      };
    } catch (error) {
      throw new Error(`API request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  async get<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.makeRequest<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.makeRequest<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async put<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.makeRequest<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.makeRequest<T>(endpoint, { method: 'DELETE' });
  }
}

// Error handling with custom error classes
class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode: number = 500, isOperational: boolean = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;

    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  public readonly field: string;
  public readonly value: any;

  constructor(field: string, value: any, message?: string) {
    super(message || `Validation failed for field: ${field}`, 400);
    this.field = field;
    this.value = value;
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string | number) {
    super(`${resource} with id ${id} not found`, 404);
  }
}

// Decorators (experimental)
function LogMethod(target: any, propertyName: string, descriptor: PropertyDescriptor) {
  const method = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${propertyName} with args:`, args);
    const result = method.apply(this, args);
    console.log(`${propertyName} returned:`, result);
    return result;
  };
}

function Validate(target: any, propertyName: string, descriptor: PropertyDescriptor) {
  const method = descriptor.value;
  descriptor.value = function (...args: any[]) {
    // Validation logic would go here
    console.log(`Validating ${propertyName}`);
    return method.apply(this, args);
  };
}

class ExampleService {
  @LogMethod
  @Validate
  public processData(data: any): any {
    return { processed: true, data };
  }
}

// Module exports and imports simulation
export {
  User,
  UserProfile,
  UserPreferences,
  ApiResponse,
  Status,
  UserRole,
  EventType,
  HttpStatus,
  LogLevel,
  BaseEntity,
  UserEntity,
  Repository,
  UserRepository,
  UserService,
  UserServiceImpl,
  TypeUtils,
  ApiClient,
  AppError,
  ValidationError,
  NotFoundError,
  ExampleService,
  isUser,
  isApiResponse,
};

// Default export
export default class Application {
  private userService: UserService;
  private apiClient: ApiClient;

  constructor(apiBaseUrl: string, apiKey: string) {
    const userRepository = new UserRepository();
    this.userService = new UserServiceImpl(userRepository);
    this.apiClient = new ApiClient(apiBaseUrl, apiKey);
  }

  async initialize(): Promise<void> {
    console.log('Application initialized');
  }

  async shutdown(): Promise<void> {
    console.log('Application shutting down');
  }
}
