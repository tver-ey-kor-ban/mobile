import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../features/auth/services/auth_api_service.dart';
import '../../features/auth/data/models/auth_models.dart';

class AuthService extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();

  bool _isAuthenticated = false;
  String? _token;
  String? _refreshToken;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  UserRolesResponse? _userRoles;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  UserRolesResponse? get userRoles => _userRoles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check if user has a specific role
  bool hasRole(String role) => _userRoles?.hasRole(role) ?? false;

  /// Check if user is admin
  bool get isAdmin => _userRoles?.isAdmin ?? false;

  /// Check if user is shop owner
  bool get isShopOwner => _userRoles?.isShopOwner ?? false;

  /// Check if user is mechanic
  bool get isMechanic => _userRoles?.isMechanic ?? false;

  /// Check if user is customer
  bool get isCustomer => _userRoles?.isCustomer ?? true;

  /// Login with username and password
  /// Calls POST /api/v1/auth/login
  Future<bool> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _authApiService.login(request);

      // Save tokens
      _token = response.accessToken;
      _refreshToken = response.refreshToken;
      _authApiService.setAuthToken(_token!);

      // Fetch user details
      await _fetchUserDetails();

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on UnauthorizedException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  /// Calls POST /api/v1/auth/register
  Future<bool> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = RegisterRequest(
        email: email,
        username: username,
        fullName: fullName,
        password: password,
        // Backend only supports 'user' role for registration
        roles: 'user',
      );

      final response = await _authApiService.register(request);

      // Auto-login after registration
      if (response.accessToken != null) {
        _token = response.accessToken;
        _refreshToken = response.accessToken;
        _authApiService.setAuthToken(_token!);
        await _fetchUserDetails();
        _isAuthenticated = true;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh access token using refresh token
  /// POST /api/v1/auth/refresh
  Future<bool> doRefreshToken() async {
    try {
      if (_refreshToken == null) return false;

      final request = RefreshTokenRequest(refreshToken: _refreshToken!);
      final response = await _authApiService.refreshToken(request);

      _token = response.accessToken;
      _refreshToken = response.refreshToken ?? _refreshToken;
      _authApiService.setAuthToken(_token!);

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Fetch current user details and roles
  /// Calls GET /api/v1/auth/me and GET /api/v1/auth/me/roles
  Future<void> _fetchUserDetails() async {
    try {
      if (_token != null) {
        _authApiService.setAuthToken(_token!);
      }

      // Fetch user details
      final user = await _authApiService.getCurrentUser();
      _userName = user.fullName;
      _userEmail = user.email;

      // Fetch user roles
      try {
        _userRoles = await _authApiService.getUserRoles();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch user roles: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch user details: $e');
      }
    }
  }

  /// Fetch user roles manually
  /// Calls GET /api/v1/auth/me/roles
  Future<bool> fetchUserRoles() async {
    try {
      if (_token != null) {
        _authApiService.setAuthToken(_token!);
      }

      _userRoles = await _authApiService.getUserRoles();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch user roles: $e');
      }
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _refreshToken = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userRoles = null;
    _error = null;
    _authApiService.clearAuthToken();
    notifyListeners();
  }

  void updateProfile({String? name, String? phone}) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    notifyListeners();
  }
}
