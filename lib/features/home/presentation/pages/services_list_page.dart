import 'package:flutter/material.dart';
import 'package:my_app/shared/widgets/popular_service_card.dart';
import 'package:my_app/shared/widgets/product_card.dart';
import 'package:my_app/shared/widgets/custom_bottom_nav.dart';
import 'package:my_app/shared/widgets/custom_chip.dart';

class ServicesListPage extends StatefulWidget {
  final String categoryName;
  final bool initialShowProducts;

  const ServicesListPage({
    super.key,
    required this.categoryName,
    this.initialShowProducts = false,
  });

  @override
  State<ServicesListPage> createState() => _ServicesListPageState();
}

class _ServicesListPageState extends State<ServicesListPage> {
  late bool showProducts;

  @override
  void initState() {
    super.initState();
    showProducts = widget.initialShowProducts;
  }

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
  ];

  final products = [
    {
      'name': 'Synthetic Oil 5W-40',
      'price': '45',
      'icon': Icons.oil_barrel,
      'colors': [Colors.blue, Colors.blueGrey],
    },
    {
      'name': 'Premium Brake Fluid',
      'price': '15',
      'icon': Icons.water_drop,
      'colors': [Colors.orange, Colors.redAccent],
    },
    {
      'name': 'Air Filter High Performance',
      'price': '25',
      'icon': Icons.air,
      'colors': [Colors.green, Colors.teal],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showProducts ? "Car Products" : widget.categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          if (showProducts)
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {},
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: Column(
        children: [
          // Selection Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomChip(
                  label: "Services",
                  isSelected: !showProducts,
                  onTap: () => setState(() => showProducts = false),
                ),
                const SizedBox(width: 20),
                CustomChip(
                  label: "Products",
                  isSelected: showProducts,
                  onTap: () => setState(() => showProducts = true),
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: showProducts ? _buildProductGrid() : _buildServiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return ListView.builder(
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
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          name: product['name'] as String,
          price: product['price'] as String,
          imageUrl: '',
          icon: product['icon'] as IconData,
          gradientColors: product['colors'] as List<Color>,
        );
      },
    );
  }
}
