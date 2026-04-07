import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../features/auth/services/auth_api_service.dart';
import '../../features/auth/data/models/auth_models.dart';

class AuthService extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();

  bool _isAuthenticated = false;
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  UserRolesResponse? _userRoles;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  UserRolesResponse? get userRoles => _userRoles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void login(
      {required String name,
      required String email,
      String? phone,
      String? token}) {
    _isAuthenticated = true;
    _token = token;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
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
