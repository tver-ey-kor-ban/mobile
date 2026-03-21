import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../../features/auth/presentation/pages/login_page.dart' as login;

/// A widget that checks authentication before allowing access to protected content.
/// If not authenticated, shows the login modal.
class AuthGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onAuthenticated;

  const AuthGuard({super.key, required this.child, this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return child;
        }
        return _buildAuthRequired(context, auth);
      },
    );
  }

  Widget _buildAuthRequired(BuildContext context, AuthService auth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please sign in to access this feature',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await login.showLoginModal(context);
              if (auth.isAuthenticated && onAuthenticated != null) {
                onAuthenticated!();
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to check auth and show login modal if needed
/// Returns true if authenticated (either already or after login), false otherwise
Future<bool> checkAuthAndShowLogin(BuildContext context) async {
  final auth = context.read<AuthService>();

  if (auth.isAuthenticated) {
    return true;
  }

  await login.showLoginModal(context);
  return auth.isAuthenticated;
}

/// Wrapper for protecting navigation - shows login modal if not authenticated
/// If authenticated, executes the onAuthenticated callback
Future<void> requireAuth(
  BuildContext context, {
  required VoidCallback onAuthenticated,
}) async {
  final auth = context.read<AuthService>();

  if (auth.isAuthenticated) {
    onAuthenticated();
    return;
  }

  await login.showLoginModal(context);

  // Check again after login modal closes
  if (context.mounted && auth.isAuthenticated) {
    onAuthenticated();
  }
}
