import 'package:flutter/material.dart';

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.phone, color: Colors.white70),
            title: Text(
              "+855 88 888 151",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.white70),
            title: Text(
              "ច័ន្ទ - ព្រហស្បតិ៍: 7:30 - 6:00",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text("ទាក់ទងមកយើង"),
          ),
        ],
      ),
    );
  }
}
