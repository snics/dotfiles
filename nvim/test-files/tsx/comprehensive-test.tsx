// =============================================================================
// React TSX Comprehensive Test File
// This file contains various React/TSX features for testing LSP and Tree-sitter
// =============================================================================

import React, {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
  useReducer,
  useContext,
  createContext,
  ReactNode,
  Component,
  PureComponent,
  forwardRef,
  useImperativeHandle,
  Suspense,
  lazy,
  memo,
  Fragment,
  StrictMode,
} from 'react';

// Type definitions for props and state
interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string;
  isOnline: boolean;
  lastSeen: Date;
  roles: string[];
}

interface UserCardProps {
  user: User;
  onEdit?: (user: User) => void;
  onDelete?: (userId: number) => void;
  className?: string;
  children?: ReactNode;
}

interface UserListProps {
  users: User[];
  loading?: boolean;
  error?: string;
  onUserSelect?: (user: User) => void;
  onLoadMore?: () => void;
  hasMore?: boolean;
}

interface UserFormProps {
  initialUser?: Partial<User>;
  onSubmit: (user: Omit<User, 'id'>) => void;
  onCancel: () => void;
  isSubmitting?: boolean;
}

interface UserFormState {
  name: string;
  email: string;
  avatar: string;
  roles: string[];
  errors: Record<string, string>;
}

// Context for user management
interface UserContextType {
  users: User[];
  currentUser: User | null;
  loading: boolean;
  error: string | null;
  addUser: (user: Omit<User, 'id'>) => Promise<void>;
  updateUser: (id: number, updates: Partial<User>) => Promise<void>;
  deleteUser: (id: number) => Promise<void>;
  setCurrentUser: (user: User | null) => void;
}

const UserContext = createContext<UserContextType | null>(null);

// Custom hooks
function useUserContext(): UserContextType {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUserContext must be used within a UserProvider');
  }
  return context;
}

function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = useCallback((value: T) => {
    try {
      setStoredValue(value);
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  }, [key]);

  return [storedValue, setValue];
}

function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

function useAsync<T, E = string>(
  asyncFunction: () => Promise<T>,
  immediate = true
) {
  const [status, setStatus] = useState<'idle' | 'pending' | 'success' | 'error'>('idle');
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<E | null>(null);

  const execute = useCallback(async () => {
    setStatus('pending');
    setData(null);
    setError(null);

    try {
      const response = await asyncFunction();
      setData(response);
      setStatus('success');
    } catch (error) {
      setError(error as E);
      setStatus('error');
    }
  }, [asyncFunction]);

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, [execute, immediate]);

  return { execute, status, data, error };
}

// Reducer for complex state management
type UserAction =
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_USERS'; payload: User[] }
  | { type: 'ADD_USER'; payload: User }
  | { type: 'UPDATE_USER'; payload: { id: number; updates: Partial<User> } }
  | { type: 'DELETE_USER'; payload: number }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'SET_CURRENT_USER'; payload: User | null };

interface UserState {
  users: User[];
  currentUser: User | null;
  loading: boolean;
  error: string | null;
}

function userReducer(state: UserState, action: UserAction): UserState {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_USERS':
      return { ...state, users: action.payload, loading: false };
    case 'ADD_USER':
      return { ...state, users: [...state.users, action.payload] };
    case 'UPDATE_USER':
      return {
        ...state,
        users: state.users.map(user =>
          user.id === action.payload.id
            ? { ...user, ...action.payload.updates }
            : user
        ),
      };
    case 'DELETE_USER':
      return {
        ...state,
        users: state.users.filter(user => user.id !== action.payload),
      };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    case 'SET_CURRENT_USER':
      return { ...state, currentUser: action.payload };
    default:
      return state;
  }
}

// Functional Components
const UserCard: React.FC<UserCardProps> = memo(({ user, onEdit, onDelete, className, children }) => {
  const [isHovered, setIsHovered] = useState(false);
  const [showActions, setShowActions] = useState(false);

  const handleEdit = useCallback(() => {
    onEdit?.(user);
  }, [onEdit, user]);

  const handleDelete = useCallback(() => {
    onDelete?.(user.id);
  }, [onDelete, user.id]);

  const statusColor = useMemo(() => {
    return user.isOnline ? 'text-green-500' : 'text-gray-400';
  }, [user.isOnline]);

  const lastSeenText = useMemo(() => {
    const now = new Date();
    const diff = now.getTime() - user.lastSeen.getTime();
    const minutes = Math.floor(diff / 60000);
    
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return `${minutes}m ago`;
    if (minutes < 1440) return `${Math.floor(minutes / 60)}h ago`;
    return `${Math.floor(minutes / 1440)}d ago`;
  }, [user.lastSeen]);

  return (
    <div
      className={`bg-white rounded-lg shadow-md p-4 transition-all duration-200 ${
        isHovered ? 'shadow-lg transform scale-105' : ''
      } ${className || ''}`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <div className="flex items-center space-x-3">
        <div className="relative">
          <img
            src={user.avatar || '/default-avatar.png'}
            alt={user.name}
            className="w-12 h-12 rounded-full object-cover"
          />
          <div className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white ${statusColor}`}>
            <div className={`w-full h-full rounded-full ${user.isOnline ? 'bg-green-500' : 'bg-gray-400'}`} />
          </div>
        </div>
        
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold text-gray-900 truncate">
            {user.name}
          </h3>
          <p className="text-sm text-gray-500 truncate">{user.email}</p>
          <p className={`text-xs ${statusColor}`}>
            {user.isOnline ? 'Online' : `Last seen ${lastSeenText}`}
          </p>
        </div>

        <div className="flex space-x-2">
          {user.roles.map(role => (
            <span
              key={role}
              className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
            >
              {role}
            </span>
          ))}
        </div>

        <div className="relative">
          <button
            onClick={() => setShowActions(!showActions)}
            className="p-2 text-gray-400 hover:text-gray-600 focus:outline-none"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
            </svg>
          </button>

          {showActions && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10">
              <div className="py-1">
                <button
                  onClick={handleEdit}
                  className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Edit User
                </button>
                <button
                  onClick={handleDelete}
                  className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                >
                  Delete User
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {children}
    </div>
  );
});

UserCard.displayName = 'UserCard';

const UserForm: React.FC<UserFormProps> = ({ initialUser, onSubmit, onCancel, isSubmitting }) => {
  const [formState, setFormState] = useState<UserFormState>({
    name: initialUser?.name || '',
    email: initialUser?.email || '',
    avatar: initialUser?.avatar || '',
    roles: initialUser?.roles || [],
    errors: {},
  });

  const [availableRoles] = useState(['admin', 'user', 'moderator', 'guest']);

  const validateForm = useCallback((): boolean => {
    const errors: Record<string, string> = {};

    if (!formState.name.trim()) {
      errors.name = 'Name is required';
    }

    if (!formState.email.trim()) {
      errors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formState.email)) {
      errors.email = 'Invalid email format';
    }

    setFormState(prev => ({ ...prev, errors }));
    return Object.keys(errors).length === 0;
  }, [formState.name, formState.email]);

  const handleSubmit = useCallback((e: React.FormEvent) => {
    e.preventDefault();
    
    if (validateForm()) {
      onSubmit({
        name: formState.name,
        email: formState.email,
        avatar: formState.avatar,
        isOnline: false,
        lastSeen: new Date(),
        roles: formState.roles,
      });
    }
  }, [formState, onSubmit, validateForm]);

  const handleInputChange = useCallback((field: keyof UserFormState, value: string | string[]) => {
    setFormState(prev => ({
      ...prev,
      [field]: value,
      errors: { ...prev.errors, [field]: '' },
    }));
  }, []);

  const toggleRole = useCallback((role: string) => {
    setFormState(prev => ({
      ...prev,
      roles: prev.roles.includes(role)
        ? prev.roles.filter(r => r !== role)
        : [...prev.roles, role],
    }));
  }, []);

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700">
          Name
        </label>
        <input
          type="text"
          id="name"
          value={formState.name}
          onChange={(e) => handleInputChange('name', e.target.value)}
          className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
            formState.errors.name ? 'border-red-300' : ''
          }`}
        />
        {formState.errors.name && (
          <p className="mt-1 text-sm text-red-600">{formState.errors.name}</p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700">
          Email
        </label>
        <input
          type="email"
          id="email"
          value={formState.email}
          onChange={(e) => handleInputChange('email', e.target.value)}
          className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
            formState.errors.email ? 'border-red-300' : ''
          }`}
        />
        {formState.errors.email && (
          <p className="mt-1 text-sm text-red-600">{formState.errors.email}</p>
        )}
      </div>

      <div>
        <label htmlFor="avatar" className="block text-sm font-medium text-gray-700">
          Avatar URL
        </label>
        <input
          type="url"
          id="avatar"
          value={formState.avatar}
          onChange={(e) => handleInputChange('avatar', e.target.value)}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Roles</label>
        <div className="mt-2 space-y-2">
          {availableRoles.map(role => (
            <label key={role} className="flex items-center">
              <input
                type="checkbox"
                checked={formState.roles.includes(role)}
                onChange={() => toggleRole(role)}
                className="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
              />
              <span className="ml-2 text-sm text-gray-700 capitalize">{role}</span>
            </label>
          ))}
        </div>
      </div>

      <div className="flex justify-end space-x-3">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isSubmitting}
          className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Saving...' : 'Save User'}
        </button>
      </div>
    </form>
  );
};

// Class Components
interface CounterState {
  count: number;
  isIncrementing: boolean;
}

class Counter extends Component<{}, CounterState> {
  private intervalId: NodeJS.Timeout | null = null;

  constructor(props: {}) {
    super(props);
    this.state = {
      count: 0,
      isIncrementing: false,
    };
  }

  componentDidMount() {
    console.log('Counter component mounted');
  }

  componentDidUpdate(prevProps: {}, prevState: CounterState) {
    if (prevState.count !== this.state.count) {
      console.log(`Count changed from ${prevState.count} to ${this.state.count}`);
    }
  }

  componentWillUnmount() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  startIncrementing = () => {
    if (this.intervalId) return;

    this.setState({ isIncrementing: true });
    this.intervalId = setInterval(() => {
      this.setState(prevState => ({
        count: prevState.count + 1,
      }));
    }, 1000);
  };

  stopIncrementing = () => {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    this.setState({ isIncrementing: false });
  };

  reset = () => {
    this.stopIncrementing();
    this.setState({ count: 0 });
  };

  render() {
    const { count, isIncrementing } = this.state;

    return (
      <div className="p-6 bg-white rounded-lg shadow-md">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Counter: {count}</h2>
        <div className="space-x-2">
          <button
            onClick={this.startIncrementing}
            disabled={isIncrementing}
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
          >
            Start
          </button>
          <button
            onClick={this.stopIncrementing}
            disabled={!isIncrementing}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50"
          >
            Stop
          </button>
          <button
            onClick={this.reset}
            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
          >
            Reset
          </button>
        </div>
      </div>
    );
  }
}

// Higher-Order Component
function withLoading<P extends object>(
  Component: React.ComponentType<P>
): React.ComponentType<P & { loading?: boolean }> {
  return function WithLoadingComponent(props: P & { loading?: boolean }) {
    const { loading, ...componentProps } = props;

    if (loading) {
      return (
        <div className="flex items-center justify-center p-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
          <span className="ml-2 text-gray-600">Loading...</span>
        </div>
      );
    }

    return <Component {...(componentProps as P)} />;
  };
}

// Render Props Pattern
interface DataFetcherProps<T> {
  url: string;
  children: (data: {
    data: T | null;
    loading: boolean;
    error: string | null;
    refetch: () => void;
  }) => ReactNode;
}

function DataFetcher<T>({ url, children }: DataFetcherProps<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return <>{children({ data, loading, error, refetch: fetchData })}</>;
}

// Context Provider
const UserProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(userReducer, {
    users: [],
    currentUser: null,
    loading: false,
    error: null,
  });

  const addUser = useCallback(async (userData: Omit<User, 'id'>) => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      const newUser: User = {
        ...userData,
        id: Date.now(), // Simple ID generation
      };
      dispatch({ type: 'ADD_USER', payload: newUser });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to add user' });
    }
  }, []);

  const updateUser = useCallback(async (id: number, updates: Partial<User>) => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      dispatch({ type: 'UPDATE_USER', payload: { id, updates } });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to update user' });
    }
  }, []);

  const deleteUser = useCallback(async (id: number) => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      dispatch({ type: 'DELETE_USER', payload: id });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: 'Failed to delete user' });
    }
  }, []);

  const setCurrentUser = useCallback((user: User | null) => {
    dispatch({ type: 'SET_CURRENT_USER', payload: user });
  }, []);

  const value: UserContextType = {
    users: state.users,
    currentUser: state.currentUser,
    loading: state.loading,
    error: state.error,
    addUser,
    updateUser,
    deleteUser,
    setCurrentUser,
  };

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
};

// Main App Component
const App: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  
  const debouncedSearchTerm = useDebounce(searchTerm, 300);
  const [favorites, setFavorites] = useLocalStorage<User[]>('favorite-users', []);

  const { users, loading, error, addUser, updateUser, deleteUser } = useUserContext();

  const filteredUsers = useMemo(() => {
    if (!debouncedSearchTerm) return users;
    return users.filter(user =>
      user.name.toLowerCase().includes(debouncedSearchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(debouncedSearchTerm.toLowerCase())
    );
  }, [users, debouncedSearchTerm]);

  const handleUserEdit = useCallback((user: User) => {
    setEditingUser(user);
    setShowForm(true);
  }, []);

  const handleUserDelete = useCallback((userId: number) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      deleteUser(userId);
    }
  }, [deleteUser]);

  const handleFormSubmit = useCallback(async (userData: Omit<User, 'id'>) => {
    try {
      if (editingUser) {
        await updateUser(editingUser.id, userData);
      } else {
        await addUser(userData);
      }
      setShowForm(false);
      setEditingUser(null);
    } catch (error) {
      console.error('Failed to save user:', error);
    }
  }, [editingUser, addUser, updateUser]);

  const handleFormCancel = useCallback(() => {
    setShowForm(false);
    setEditingUser(null);
  }, []);

  const toggleFavorite = useCallback((user: User) => {
    setFavorites(prev => {
      const isFavorite = prev.some(fav => fav.id === user.id);
      if (isFavorite) {
        return prev.filter(fav => fav.id !== user.id);
      } else {
        return [...prev, user];
      }
    });
  }, [setFavorites]);

  if (loading && users.length === 0) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    );
  }

  return (
    <StrictMode>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900">User Management</h1>
            <p className="mt-2 text-gray-600">Manage your users with ease</p>
          </div>

          {error && (
            <div className="mb-6 bg-red-50 border border-red-200 rounded-md p-4">
              <div className="flex">
                <div className="flex-shrink-0">
                  <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-red-800">Error</h3>
                  <div className="mt-2 text-sm text-red-700">{error}</div>
                </div>
              </div>
            </div>
          )}

          <div className="mb-6 flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <input
                type="text"
                placeholder="Search users..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>
            <button
              onClick={() => setShowForm(true)}
              className="px-4 py-2 bg-indigo-600 text-white rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Add User
            </button>
          </div>

          {showForm && (
            <div className="mb-6 bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">
                {editingUser ? 'Edit User' : 'Add New User'}
              </h2>
              <UserForm
                initialUser={editingUser || undefined}
                onSubmit={handleFormSubmit}
                onCancel={handleFormCancel}
                isSubmitting={loading}
              />
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredUsers.map(user => (
              <UserCard
                key={user.id}
                user={user}
                onEdit={handleUserEdit}
                onDelete={handleUserDelete}
              >
                <div className="mt-4 pt-4 border-t border-gray-200">
                  <button
                    onClick={() => toggleFavorite(user)}
                    className={`w-full px-3 py-2 text-sm font-medium rounded-md ${
                      favorites.some(fav => fav.id === user.id)
                        ? 'bg-yellow-100 text-yellow-800 hover:bg-yellow-200'
                        : 'bg-gray-100 text-gray-800 hover:bg-gray-200'
                    }`}
                  >
                    {favorites.some(fav => fav.id === user.id) ? '★ Favorited' : '☆ Add to Favorites'}
                  </button>
                </div>
              </UserCard>
            ))}
          </div>

          {filteredUsers.length === 0 && !loading && (
            <div className="text-center py-12">
              <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
              </svg>
              <h3 className="mt-2 text-sm font-medium text-gray-900">No users found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchTerm ? 'Try adjusting your search terms.' : 'Get started by adding a new user.'}
              </p>
            </div>
          )}

          <Counter />
        </div>
      </div>
    </StrictMode>
  );
};

// Lazy loading example
const LazyComponent = lazy(() => import('./LazyComponent'));

// Error Boundary
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends Component<
  { children: ReactNode },
  ErrorBoundaryState
> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="p-6 bg-red-50 border border-red-200 rounded-md">
          <h2 className="text-lg font-semibold text-red-800">Something went wrong</h2>
          <p className="mt-2 text-red-700">
            {this.state.error?.message || 'An unexpected error occurred'}
          </p>
        </div>
      );
    }

    return this.props.children;
  }
}

// Main export with providers
const AppWithProviders: React.FC = () => (
  <ErrorBoundary>
    <UserProvider>
      <Suspense fallback={<div>Loading...</div>}>
        <App />
      </Suspense>
    </UserProvider>
  </ErrorBoundary>
);

export default AppWithProviders;
export { UserCard, UserForm, Counter, withLoading, DataFetcher, UserProvider, useUserContext };
