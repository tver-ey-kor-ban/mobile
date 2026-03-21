import 'package:flutter/material.dart';

class StepThreeSummary extends StatelessWidget {
  final String userName;
  final String phone;
  final String date;
  final String time;
  final List<String> selectedServices;
  final double total;

  const StepThreeSummary({
    super.key,
    required this.userName,
    required this.phone,
    required this.date,
    required this.time,
    required this.selectedServices,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ផ្ទៀងផ្ទាត់ការកក់',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Summary Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, userName),
                _buildInfoRow(Icons.phone, phone),
                _buildInfoRow(Icons.calendar_today, '$date - $time'),
                const Divider(),
                ...selectedServices.map(
                  (service) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(service), const Text('Selected')],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        // Total Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'សរុប',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                '\$$total',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}
