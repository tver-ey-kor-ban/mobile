import 'package:flutter/material.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'សេវាកម្មម៉ាស៊ីន',
        'icon': Icons.settings_input_component,
        'color': Colors.blue,
      },
      {
        'name': 'ប្តូរប្រេងម៉ាស៊ីន',
        'icon': Icons.opacity,
        'color': Colors.purple,
      },
      {'name': 'កម្លាំងម៉ាស៊ីន', 'icon': Icons.speed, 'color': Colors.orange},
      {'name': 'របាំងការពារ', 'icon': Icons.shield, 'color': Colors.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                services[index]['icon'] as IconData,
                color: services[index]['color'] as Color,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                services[index]['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
