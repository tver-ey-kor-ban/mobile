import 'package:flutter/material.dart';
// 1. Feature-specific widgets
import 'package:my_app/features/home/presentation/widgets/home_header.dart';
import 'package:my_app/features/home/presentation/widgets/contact_info_section.dart';
import 'package:my_app/features/home/presentation/widgets/quick_action_card.dart';
import 'package:my_app/features/home/presentation/widgets/services_grid.dart';
import 'package:my_app/features/home/presentation/widgets/ready_to_start_banner.dart';
// 2. Shared widgets
import 'package:my_app/shared/widgets/section_header.dart';
import 'package:my_app/shared/widgets/custom_bottom_nav.dart';
import 'package:my_app/shared/widgets/popular_service_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(), // Your shared bottom nav
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(), // The gradient + stats part
            QuickActionFloatingCard(), // The 3-icon white card

            SectionHeader(title: "Our Services"),
            ServicesGrid(), // 2x2 Grid

            SectionHeader(title: "Popular Services"),
            // Map your service data here
            const PopularServiceCard(
              title: "Oil Change",
              price: "25",
              rating: 4.8,
              icon: Icons.opacity,
              gradientColors: [Colors.purple, Colors.deepPurple],
            ),
            const PopularServiceCard(
              title: "New Tires",
              price: "35",
              rating: 4.7,
              icon: Icons.tire_repair,
              gradientColors: [Colors.blue, Colors.lightBlue],
            ),

            ContactInfoSection(), // Dark card at bottom
            ReadyToStartBanner(), // Orange CTA banner
          ],
        ),
      ),
    );
  }
}
