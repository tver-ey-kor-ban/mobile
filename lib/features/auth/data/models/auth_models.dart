/// Model for login request
/// POST /api/v1/auth/login
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

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
  final String? refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle different possible token field names from backend
    final token =
        json['access_token'] ?? json['accessToken'] ?? json['token'] ?? '';
    return LoginResponse(
      accessToken: token,
      tokenType: json['token_type'] ?? json['tokenType'] ?? 'bearer',
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
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
  final bool isActive;
  final bool isSuperuser;
  final String roles;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.fullName,
    required this.password,
    this.isActive = true,
    this.isSuperuser = false,
    this.roles = 'user',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'full_name': fullName,
      'password': password,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'roles': roles,
    };
  }
}

/// Model for register response
class RegisterResponse {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final bool isActive;
  final bool isSuperuser;
  final String roles;
  final String? accessToken;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.isActive,
    required this.isSuperuser,
    required this.roles,
    this.accessToken,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      isActive: json['is_active'] ?? true,
      isSuperuser: json['is_superuser'] ?? false,
      roles: json['roles'] ?? 'user',
      accessToken: json['access_token'] ?? json['accessToken'] ?? json['token'],
    );
  }
}

/// Model for refresh token request
/// POST /api/v1/auth/refresh
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
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
  final List<String> roles;

  UserRolesResponse({
    required this.roles,
  });

  factory UserRolesResponse.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] as List<dynamic>?;
    return UserRolesResponse(
      roles: rolesList?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is shop owner
  bool get isShopOwner => hasRole('shop_owner') || hasRole('owner');

  /// Check if user is mechanic
  bool get isMechanic => hasRole('mechanic');

  /// Check if user is customer
  bool get isCustomer => hasRole('customer') || roles.isEmpty;
}
