import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart' as login;
import '../../../auth/presentation/pages/register_page.dart' as register;
import '../../../shop/presentation/pages/create_shop_page.dart';
import '../../../appointments/presentation/pages/my_appointments_page.dart';
import '../../../vehicles/presentation/pages/my_vehicles_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../repair_progress/presentation/pages/my_repairs_page.dart';
import '../../../quotations/presentation/pages/my_quotations_page.dart';
import '../../../invoices/presentation/pages/my_invoices_page.dart';
import '../../../mechanic/presentation/pages/mechanic_dashboard_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return _buildLoggedInView(context, auth);
          }
          return _buildLoggedOutView(context);
        },
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline,
                  size: 50, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            const Text('Welcome!',
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your profile and\nmanage your bookings',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => login.showLoginModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Sign In',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => register.showRegisterModal(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create Account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthService auth) {
    String userRole = 'Customer';
    if (auth.isAdmin) {
      userRole = 'Admin';
    } else if (auth.isShopOwner) {
      userRole = 'Shop Owner';
    } else if (auth.isMechanic) {
      userRole = 'Mechanic';
    } else if (auth.userRoles != null && auth.userRoles!.roles.isNotEmpty) {
      final role = auth.userRoles!.roles.first;
      userRole = role[0].toUpperCase() + role.substring(1);
    }

    final isTechnical = auth.isMechanic || auth.isShopOwner;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(auth, userRole),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Technical panel
                if (isTechnical) ...[
                  _buildMenuTile(
                    icon: Icons.dashboard_outlined,
                    title: 'My Dashboard',
                    subtitle: 'Manage bookings & orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MechanicDashboardPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Shop Owner extras
                if (auth.isShopOwner) ...[
                  _buildMenuTile(
                    icon: Icons.store_outlined,
                    title: 'Create / Manage Shop',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateShopPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Customer sections
                if (!isTechnical) ...[
                  _buildMenuTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'My Appointments',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyAppointmentsPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMenuTile(
                    icon: Icons.directions_car_outlined,
                    title: 'My Vehicles',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyVehiclesPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMenuTile(
                    icon: Icons.build_circle_outlined,
                    title: 'Repair Progress',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyRepairsPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'My Quotations',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyQuotationsPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMenuTile(
                    icon: Icons.receipt_outlined,
                    title: 'My Invoices',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyInvoicesPage()),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Common
                _buildMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsPage()),
                  ),
                ),
                const SizedBox(height: 4),
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    // TODO: Edit profile form
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Help page
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Logged out successfully')),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthService auth, String userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              (auth.userName ?? 'U').substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            auth.userName ?? 'User',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 2),
          if (auth.username != null)
            Text(
              '@${auth.username}',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8)),
            ),
          if (auth.userEmail != null) ...[
            const SizedBox(height: 2),
            Text(
              auth.userEmail!,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              userRole,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.red.shade700),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
