import 'package:flutter/material.dart';
import 'package:my_app/features/booking/presentation/pages/booking_page.dart';

class PopularServiceCard extends StatelessWidget {
  final String title;
  final String price;
  final double rating;

  const PopularServiceCard({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Replaces ListTile contentPadding
        child: Row(
          children: [
            // Leading Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.oil_barrel, color: Colors.red),
            ),
            const SizedBox(width: 12),

            // Title and Subtitle (Expanded makes it take remaining space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      Text(" $rating"),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing Price and Button
            Column(
              children: [
                Text(
                  "\$$price",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8), // Added spacing
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 35), // Control button size
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text("Book"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
