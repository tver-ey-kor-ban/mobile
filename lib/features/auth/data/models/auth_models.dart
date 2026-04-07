/// Model for login request
/// POST /api/v1/auth/login
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  Map<String, String> toFormData() {
    return {
      'username': username,
      'password': password,
      'grant_type': 'password',
    };
  }
}

/// Model for login response
class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}

/// Model for register request
/// POST /api/v1/auth/register
class RegisterRequest {
  final String email;
  final String username;
  final String fullName;
  final String password;
  final String roles;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.fullName,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'full_name': fullName,
      'password': password,
      'roles': roles,
    };
  }
}

/// Model for register response
class RegisterResponse {
  final String? accessToken;
  final String message;

  RegisterResponse({
    this.accessToken,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      accessToken: json['access_token'],
      message: json['message'] ?? 'Registration successful',
    );
  }
}

/// Model for get current user response
/// GET /api/v1/auth/me
class UserResponse {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final bool isActive;

  UserResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.isActive,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

/// Model for user roles response
/// GET /api/v1/auth/me/roles
class UserRolesResponse {
  final String username;
  final List<String> roles;
  final bool isSuperuser;

  UserRolesResponse({
    required this.username,
    required this.roles,
    required this.isSuperuser,
  });

  factory UserRolesResponse.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] ?? [];
    return UserRolesResponse(
      username: json['username'] ?? '',
      roles: (rolesList as List).map((r) => r.toString()).toList(),
      isSuperuser: json['is_superuser'] ?? false,
    );
  }

  /// Check if user has a specific role
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// Check if user is admin
  bool get isAdmin => isSuperuser || roles.contains('admin');

  /// Check if user is shop owner
  bool get isShopOwner => roles.contains('owner') || roles.contains('shop_owner');

  /// Check if user is mechanic
  bool get isMechanic => roles.contains('mechanic');

  /// Check if user is customer
  bool get isCustomer => roles.contains('user') || roles.contains('customer');
}
