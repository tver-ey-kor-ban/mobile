import 'package:flutter/material.dart';
import 'package:my_app/features/home/presentation/pages/services_list_page.dart';
import 'package:my_app/features/home/presentation/pages/home_page.dart';
import 'package:my_app/features/profile/presentation/pages/profile_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, this.currentIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const ServicesListPage(categoryName: "All Services"),
          ),
        );
        break;
      case 2:
        // Activity - navigate to activity page (requires auth)
        // TODO: Create activity page
        break;
      case 3:
        // Profile - navigate to profile page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
