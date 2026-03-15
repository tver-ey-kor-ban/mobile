import 'package:flutter/material.dart';

class CarService {
  final String id;
  final String title;
  final String subtitle;
  final double rating;
  final int reviews;
  final double price;
  final String imagePath; // Local path or URL
  final String tag; // e.g., "Popular", "Top Rated"
  final List<Color> gradient;

  const CarService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imagePath,
    required this.tag,
    required this.gradient,
  });

  // Factory to handle JSON serialization (useful for API integration)
  factory CarService.fromJson(Map<String, dynamic> json) {
    return CarService(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'],
      price: (json['price'] as num).toDouble(),
      imagePath: json['imagePath'],
      tag: json['tag'],
      gradient: [Color(json['colorStart']), Color(json['colorEnd'])],
    );
  }
}
