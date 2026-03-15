import 'package:flutter/material.dart';

class ReadyToStartBanner extends StatelessWidget {
  const ReadyToStartBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE53935)], // Orange to Red
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            "តើអ្នករួចរាល់ហើយឬនៅ?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ready to Start Your Service?",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Action for getting started
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              "Get Started Now",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
