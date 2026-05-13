import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/auth_service.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/shop_list_page.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/mechanic/presentation/pages/mechanic_dashboard_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, this.currentIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    final isTechnical = auth.isMechanic || auth.isShopOwner;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShopListPage()),
        );
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isTechnical && auth.isAuthenticated
                ? const MechanicDashboardPage()
                : const ActivityPage(),
          ),
        );
      case 3:
        if (isTechnical && auth.isAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isTechnical = auth.isMechanic || auth.isShopOwner;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        const BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined), label: 'Shops'),
        BottomNavigationBarItem(
          icon: Icon(
              isTechnical ? Icons.dashboard_outlined : Icons.history),
          label: isTechnical ? 'Dashboard' : 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              isTechnical ? Icons.notifications_outlined : Icons.person),
          label: isTechnical ? 'Alerts' : 'Profile',
        ),
      ],
    );
  }
}
