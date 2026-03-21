import 'package:flutter/material.dart';

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
              color: Colors.black.withOpacity(0.1),
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
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
