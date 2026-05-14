import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/auth/services/auth_api_service.dart';
import '../../core/network/api_client.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _refreshToken;
  int? _userId;
  String? _userName;
  String? _username;
  String? _userEmail;
  String? _userPhone;
  bool _isLoading = false;
  String? _error;
  UserRolesResponse? _userRoles;
  int? _shopId;

  final ApiClient _apiClient;
  late final AuthApiService _authApiService;

  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyUserName = 'auth_user_name';
  static const _keyUsername = 'auth_username';
  static const _keyUserEmail = 'auth_user_email';

  AuthService() : _apiClient = ApiClient() {
    _authApiService = AuthApiService(apiClient: _apiClient);
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get username => _username;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserRolesResponse? get userRoles => _userRoles;
  int? get shopId => _shopId;
  ApiClient get apiClient => _apiClient;

  bool get isAdmin => _userRoles?.isAdmin ?? false;
  bool get isShopOwner => _userRoles?.isShopOwner ?? false;
  bool get isMechanic => _userRoles?.isMechanic ?? false;
  bool get isCustomer => !isAdmin && !isShopOwner && !isMechanic;

  /// Call this once at app startup (in main.dart or root widget)
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_keyToken);
    if (savedToken == null) return;

    _token = savedToken;
    _refreshToken = prefs.getString(_keyRefreshToken);
    _userId = prefs.getInt(_keyUserId);
    _userName = prefs.getString(_keyUserName);
    _username = prefs.getString(_keyUsername);
    _userEmail = prefs.getString(_keyUserEmail);
    _apiClient.setAuthToken(savedToken);

    try {
      final roles = await _authApiService.getUserRoles();
      _userRoles = roles;
      _isAuthenticated = true;
    } catch (_) {
      // Token expired or invalid — clear session
      await _clearPrefs();
      _token = null;
      _apiClient.clearAuthToken();
    }

    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _authApiService.register(
        RegisterRequest(
          email: email,
          username: username,
          fullName: fullName,
          password: password,
        ),
      );
      final success = await loginWithCredentials(
        username: username,
        password: password,
      );
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final loginResponse = await _authApiService.login(
        LoginRequest(username: username, password: password),
      );

      _apiClient.setAuthToken(loginResponse.accessToken);

      final user = await _authApiService.getCurrentUser();
      final roles = await _authApiService.getUserRoles();

      _isAuthenticated = true;
      _token = loginResponse.accessToken;
      _refreshToken = loginResponse.refreshToken;
      _userId = user.id;
      _userName = user.fullName.isNotEmpty ? user.fullName : user.username;
      _username = user.username;
      _userEmail = user.email;
      _userRoles = roles;

      await _saveToPrefs();

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _apiClient.clearAuthToken();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void login({
    required String name,
    required String email,
    String? phone,
    String? token,
  }) {
    _isAuthenticated = true;
    _token = token;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    if (token != null) _apiClient.setAuthToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _refreshToken = null;
    _userId = null;
    _userName = null;
    _username = null;
    _userEmail = null;
    _userPhone = null;
    _userRoles = null;
    _shopId = null;
    _apiClient.clearAuthToken();
    await _clearPrefs();
    notifyListeners();
  }

  void updateProfile({String? name, String? phone}) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    notifyListeners();
  }

  void setShopId(int id) {
    _shopId = id;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_keyToken, _token!);
    if (_refreshToken != null) await prefs.setString(_keyRefreshToken, _refreshToken!);
    if (_userId != null) await prefs.setInt(_keyUserId, _userId!);
    if (_userName != null) await prefs.setString(_keyUserName, _userName!);
    if (_username != null) await prefs.setString(_keyUsername, _username!);
    if (_userEmail != null) await prefs.setString(_keyUserEmail, _userEmail!);
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyUserEmail);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
