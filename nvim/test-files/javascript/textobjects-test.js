// 🧪 TEXTOBJECTS TEST FILE
// Test alle nvim-treesitter-textobjects features hier

class UserManager {
  constructor(apiUrl) {
    this.apiUrl = apiUrl;
    this.users = [];
    this.cache = new Map();
  }

  // Method with multiple parameters
  async createUser(username, email, password, options = {}) {
    if (!username || !email) {
      throw new error("username and email are required");
    }

    const userdata = {
      username: username.trim(),
      email: email.tolowercase(),
      password: await this.hashpassword(password),
      createdat: new date(),
      isactive: true,
      permissions: options.permissions || ["read"],
      profile: {
        firstname: options.firstname || "",
        lastname: options.lastname || "",
        avatar: options.avatar || null,
      },
    };

    // validation loop
    for (const key of object.keys(userdata)) {
      if (userdata[key] === undefined) {
        delete userdata[key];
      }
    }

    const result = await this.saveuser(userdata);
    this.users.push(result);
    return result;
  }

  async hashPassword(password) {
    const salt = Math.random().toString(36);
    return btoa(password + salt);
  }

  // Function with conditionals and loops
  findUsersByRole(role) {
    const matchingUsers = [];

    for (let i = 0; i < this.users.length; i++) {
      const user = this.users[i];

      if (user.permissions && user.permissions.includes(role)) {
        if (user.isActive) {
          matchingUsers.push({
            id: user.id,
            username: user.username,
            email: user.email,
          });
        } else {
          console.log(`Skipping inactive user: ${user.username}`);
        }
      }
    }

    return matchingUsers;
  }

  // Method with nested conditionals
  async updateUserPermissions(userId, newPermissions) {
    const user = this.users.find((u) => u.id === userId);

    if (!user) {
      throw new Error("User not found");
    }

    if (Array.isArray(newPermissions)) {
      if (newPermissions.length > 0) {
        user.permissions = [...newPermissions];
        await this.saveUser(user);
        return true;
      } else {
        console.warn("Empty permissions array provided");
        return false;
      }
    } else {
      console.error("Permissions must be an array");
      return false;
    }
  }

  // Generator function
  *getAllActiveUsers() {
    for (const user of this.users) {
      if (user.isActive) {
        yield user;
      }
    }
  }

  // Arrow function with complex logic
  filterUsers = (criteria) => {
    return this.users.filter((user) => {
      if (
        criteria.isActive !== undefined &&
        user.isActive !== criteria.isActive
      ) {
        return false;
      }

      if (criteria.hasPermission) {
        if (
          !user.permissions ||
          !user.permissions.includes(criteria.hasPermission)
        ) {
          return false;
        }
      }

      if (criteria.searchTerm) {
        const searchLower = criteria.searchTerm.toLowerCase();
        return (
          user.username.toLowerCase().includes(searchLower) ||
          user.email.toLowerCase().includes(searchLower)
        );
      }

      return true;
    });
  };

  // Async method with error handling
  async saveUser(userData) {
    try {
      const response = await fetch(`${this.apiUrl}/users`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(userData),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const savedUser = await response.json();
      this.cache.set(savedUser.id, savedUser);
      return savedUser;
    } catch (error) {
      console.error("Failed to save user:", error);
      throw error;
    }
  }
}

// Standalone function with switch statement
function processUserAction(action, payload) {
  switch (action) {
    case "CREATE":
      return { type: "USER_CREATED", data: payload };
    case "UPDATE":
      return { type: "USER_UPDATED", data: payload };
    case "DELETE":
      return { type: "USER_DELETED", id: payload.id };
    default:
      throw new Error(`Unknown action: ${action}`);
  }
}

// Function with nested loops and conditionals
function analyzeUserActivity(users, timeRange) {
  const analysis = {
    activeUsers: 0,
    inactiveUsers: 0,
    byPermission: {},
  };

  for (let i = 0; i < users.length; i++) {
    const user = users[i];

    if (user.lastLogin && isWithinTimeRange(user.lastLogin, timeRange)) {
      analysis.activeUsers++;
    } else {
      analysis.inactiveUsers++;
    }

    // Analyze permissions
    if (user.permissions) {
      for (const permission of user.permissions) {
        if (!analysis.byPermission[permission]) {
          analysis.byPermission[permission] = 0;
        }
        analysis.byPermission[permission]++;
      }
    }
  }

  return analysis;
}

// Helper function
function isWithinTimeRange(date, range) {
  const now = new Date();
  const checkDate = new Date(date);
  const diffDays = (now - checkDate) / (1000 * 60 * 60 * 24);
  return diffDays <= range.days;
}

// Export
export { UserManager, processUserAction, analyzeUserActivity };
