import 'package:flutter/material.dart';
import '../../../search/presentation/pages/image_search_page.dart';

class QuickActionFloatingCard extends StatelessWidget {
  const QuickActionFloatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(
        0.0,
        -0.5,
      ), // Moves the widget up by 50% of its own height
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ), // Only side margins now
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(Icons.calendar_month, 'ការកក់ទុក', Colors.orange),
            _buildItem(Icons.analytics, 'ប្រតិបត្តិការ', Colors.indigo),
            _buildItem(Icons.description, 'វិក្កយបត្រ', Colors.blueGrey),
            _buildItemButton(
              context,
              Icons.camera_alt,
              'ស្វែងរករូប',
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageSearchPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
