import 'package:flutter/material.dart';
import 'package:my_app/shared/widgets/popular_service_card.dart';
import 'package:my_app/shared/widgets/custom_bottom_nav.dart';

class ServicesListPage extends StatelessWidget {
  final String categoryName;

  const ServicesListPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Mock data for services based on category
    final services = [
      {
        'title': 'Premium Oil Change',
        'price': '45',
        'rating': 4.9,
        'icon': Icons.opacity,
        'colors': [Colors.purple, Colors.deepPurple],
      },
      {
        'title': 'Standard Oil Change',
        'price': '25',
        'rating': 4.7,
        'icon': Icons.oil_barrel,
        'colors': [Colors.blue, Colors.lightBlue],
      },
      {
        'title': 'Engine Diagnostics',
        'price': '60',
        'rating': 4.8,
        'icon': Icons.settings_suggest,
        'colors': [Colors.orange, Colors.deepOrange],
      },
      {
        'title': 'Full Synthetic Oil',
        'price': '85',
        'rating': 5.0,
        'icon': Icons.science,
        'colors': [Colors.green, Colors.teal],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return PopularServiceCard(
            title: service['title'] as String,
            price: service['price'] as String,
            rating: service['rating'] as double,
            icon: service['icon'] as IconData,
            gradientColors: service['colors'] as List<Color>,
            tag: index == 0 ? "Best Seller" : "Recommended",
          );
        },
      ),
    );
  }
}
