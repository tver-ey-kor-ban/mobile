import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // We remove 'const' from Container because it contains dynamic children
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFFB71C1C)], // Navy to Red
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // 1. Top Pill Badge
          _buildPillBadge(),
          const SizedBox(height: 20),

          // 2. Khmer Title Text
          const Text(
            'សេវាកម្ម\nដែលទុកចិត្ត',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 30),

          // 3. Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('5000+', 'អតិថិជន'),
              _statItem('50+', 'អ្នកជំនាញ'),
              _statItem('24/7', 'គាំទ្រ'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Stats
  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // Helper Widget for the "Premium" pill
  Widget _buildPillBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: Colors.orange, size: 16),
          SizedBox(width: 4),
          Text(
            'Premium Car Care Service',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
