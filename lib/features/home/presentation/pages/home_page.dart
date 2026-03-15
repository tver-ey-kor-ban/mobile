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
import 'package:my_app/features/home/presentation/pages/services_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            QuickActionFloatingCard(),

            SectionHeader(title: "Our Services"),
            ServicesGrid(),

            SectionHeader(title: "Popular Services"),
            // Map your service data here
            PopularServiceCard(title: "Oil Change", price: "25", rating: 4.8),
            PopularServiceCard(title: "New Tires", price: "35", rating: 4.7),
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


            SectionHeader(title: "Featured Products"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSmallProduct(context, "Synthetic Oil", "45", Icons.oil_barrel, Colors.blue),
                    const SizedBox(width: 15),
                    _buildSmallProduct(context, "Air Filter", "25", Icons.air, Colors.green),
                    const SizedBox(width: 15),
                    _buildSmallProduct(context, "Brake Fluid", "15", Icons.water_drop, Colors.orange),
                  ],
                ),
              ),
            ),

            ContactInfoSection(),
            ReadyToStartBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallProduct(BuildContext context, String name, String price, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ServicesListPage(
              categoryName: "Car Products",
              initialShowProducts: true,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$$price",
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
