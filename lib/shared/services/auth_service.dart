import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  String? _userPhone;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;

  void login({required String name, required String email, String? phone}) {
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone}) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    notifyListeners();
  }
}
