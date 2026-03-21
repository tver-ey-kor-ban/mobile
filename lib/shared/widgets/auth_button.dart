import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/pages/login_page.dart' as login;
import '../../features/auth/presentation/pages/register_page.dart' as register;
import '../services/auth_service.dart';

class AuthButton extends StatelessWidget {
  final AuthButtonType type;
  final bool isOutlined;

  const AuthButton({
    super.key,
    this.type = AuthButtonType.login,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: () => _handlePress(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(_getLabel()),
      );
    }

    return ElevatedButton(
      onPressed: () => _handlePress(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(_getLabel()),
    );
  }

  String _getLabel() {
    switch (type) {
      case AuthButtonType.login:
        return 'Sign In';
      case AuthButtonType.register:
        return 'Sign Up';
    }
  }

  void _handlePress(BuildContext context) {
    switch (type) {
      case AuthButtonType.login:
        login.showLoginModal(context);
        break;
      case AuthButtonType.register:
        register.showRegisterModal(context);
        break;
    }
  }
}

enum AuthButtonType { login, register }

/// A row with both login and register buttons
/// Shows user info when logged in
class AuthButtonsRow extends StatelessWidget {
  const AuthButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return _buildUserInfo(context, auth);
        }
        return _buildAuthButtons(context);
      },
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthService auth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.red.shade700,
            child: Text(
              auth.userName?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  auth.userEmail ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              auth.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: AuthButton(type: AuthButtonType.login, isOutlined: true),
        ),
        SizedBox(width: 16),
        Expanded(child: AuthButton(type: AuthButtonType.register)),
      ],
    );
  }
}
