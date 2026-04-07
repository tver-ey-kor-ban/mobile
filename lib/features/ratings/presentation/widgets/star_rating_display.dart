import 'package:flutter/material.dart';

/// A reusable star rating display widget
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showValue;
  final int? reviewCount;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.showValue = true,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            final starValue = index + 1;
            IconData icon;
            Color color;

            if (rating >= starValue) {
              // Full star
              icon = Icons.star;
              color = Colors.amber;
            } else if (rating >= starValue - 0.5) {
              // Half star
              icon = Icons.star_half;
              color = Colors.amber;
            } else {
              // Empty star
              icon = Icons.star_border;
              color = Colors.grey.shade400;
            }

            return Icon(
              icon,
              color: color,
              size: size,
            );
          }),
        ),

        // Rating value
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],

        // Review count
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}

/// A compact rating badge widget
class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: size,
            color: _getRatingColor(rating),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(rating),
            ),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: TextStyle(
                fontSize: size * 0.85,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.amber;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }
}
