import 'dart:io';

/// Service for image-based product search
/// NOTE: Currently returns static mock data. Replace with actual API calls when endpoint is ready.
class ImageSearchService {
  /// Search products by uploading an image
  /// Returns a list of similar products (STATIC - Mock data for now)
  Future<ImageSearchResult> searchByImage(
    File imageFile, {
    int limit = 10,
    double? minSimilarity,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return static mock data
    return ImageSearchResult(
      products: [
        SimilarProduct(
          id: 1,
          name: 'Brake Pad Set - Toyota Camry 2020',
          description: 'High-quality ceramic brake pads for Toyota Camry',
          price: 45.99,
          currency: 'USD',
          similarityScore: 0.95,
          imageUrl: 'https://via.placeholder.com/150',
          category: 'Brakes',
          brand: 'Bosch',
        ),
        SimilarProduct(
          id: 2,
          name: 'Engine Oil Filter',
          description: 'Premium oil filter for various vehicle models',
          price: 12.50,
          currency: 'USD',
          similarityScore: 0.87,
          imageUrl: 'https://via.placeholder.com/150',
          category: 'Engine',
          brand: 'Mann-Filter',
        ),
        SimilarProduct(
          id: 3,
          name: 'Air Filter - Honda Civic',
          description: 'OEM replacement air filter',
          price: 18.99,
          currency: 'USD',
          similarityScore: 0.82,
          imageUrl: 'https://via.placeholder.com/150',
          category: 'Engine',
          brand: 'Honda Genuine',
        ),
        SimilarProduct(
          id: 4,
          name: 'Spark Plug Set (4 pcs)',
          description: 'Iridium spark plugs for better performance',
          price: 32.00,
          currency: 'USD',
          similarityScore: 0.78,
          imageUrl: 'https://via.placeholder.com/150',
          category: 'Ignition',
          brand: 'NGK',
        ),
        SimilarProduct(
          id: 5,
          name: 'Wiper Blade 26"',
          description: 'All-season wiper blade',
          price: 15.99,
          currency: 'USD',
          similarityScore: 0.71,
          imageUrl: 'https://via.placeholder.com/150',
          category: 'Wipers',
          brand: 'Rain-X',
        ),
      ],
      totalResults: 5,
      searchId: 'mock-search-001',
      message: 'Static results - API endpoint not yet available',
    );
  }

  /// Search products with additional text query combined with image
  /// (STATIC - Mock data for now)
  Future<ImageSearchResult> searchByImageAndText(
    File imageFile,
    String textQuery, {
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Filter mock products based on text query (simple contains check)
    final allProducts = [
      SimilarProduct(
        id: 1,
        name: 'Brake Pad Set - Toyota Camry 2020',
        description: 'High-quality ceramic brake pads for Toyota Camry',
        price: 45.99,
        currency: 'USD',
        similarityScore: 0.95,
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Brakes',
        brand: 'Bosch',
      ),
      SimilarProduct(
        id: 2,
        name: 'Engine Oil Filter',
        description: 'Premium oil filter for various vehicle models',
        price: 12.50,
        currency: 'USD',
        similarityScore: 0.87,
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Engine',
        brand: 'Mann-Filter',
      ),
      SimilarProduct(
        id: 3,
        name: 'Air Filter - Honda Civic',
        description: 'OEM replacement air filter',
        price: 18.99,
        currency: 'USD',
        similarityScore: 0.82,
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Engine',
        brand: 'Honda Genuine',
      ),
      SimilarProduct(
        id: 4,
        name: 'Spark Plug Set (4 pcs)',
        description: 'Iridium spark plugs for better performance',
        price: 32.00,
        currency: 'USD',
        similarityScore: 0.78,
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Ignition',
        brand: 'NGK',
      ),
      SimilarProduct(
        id: 5,
        name: 'Wiper Blade 26"',
        description: 'All-season wiper blade',
        price: 15.99,
        currency: 'USD',
        similarityScore: 0.71,
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Wipers',
        brand: 'Rain-X',
      ),
    ];

    final filteredProducts = textQuery.isEmpty
        ? allProducts
        : allProducts
            .where((p) =>
                p.name.toLowerCase().contains(textQuery.toLowerCase()) ||
                p.category!.toLowerCase().contains(textQuery.toLowerCase()))
            .toList();

    return ImageSearchResult(
      products: filteredProducts.take(limit).toList(),
      totalResults: filteredProducts.length,
      searchId: 'mock-search-text-001',
      message: 'Static results - API endpoint not yet available',
    );
  }
}

/// Model for image search result
class ImageSearchResult {
  final List<SimilarProduct> products;
  final int totalResults;
  final String? searchId;
  final String? message;

  ImageSearchResult({
    required this.products,
    required this.totalResults,
    this.searchId,
    this.message,
  });

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    final productsList =
        json['products'] ?? json['results'] ?? json['items'] ?? [];
    return ImageSearchResult(
      products: (productsList as List)
          .map((item) => SimilarProduct.fromJson(item))
          .toList(),
      totalResults:
          json['total'] ?? json['total_results'] ?? json['count'] ?? 0,
      searchId: json['search_id'],
      message: json['message'],
    );
  }
}

/// Model for a similar product found by image search
class SimilarProduct {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? currency;
  final double similarityScore;
  final String? imageUrl;
  final String? category;
  final String? brand;
  final Map<String, dynamic>? additionalData;

  SimilarProduct({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.currency,
    required this.similarityScore,
    this.imageUrl,
    this.category,
    this.brand,
    this.additionalData,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    return SimilarProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Unknown Product',
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] ?? 'USD',
      similarityScore: json['similarity'] ??
          json['similarity_score'] ??
          json['score'] ??
          0.0,
      imageUrl: json['image_url'] ?? json['image'] ?? json['thumbnail'],
      category: json['category'],
      brand: json['brand'],
      additionalData: json,
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    if (price == null) return 'Price not available';
    return '${currency ?? "USD"} ${price!.toStringAsFixed(2)}';
  }

  /// Get similarity percentage
  String get similarityPercentage {
    return '${(similarityScore * 100).toStringAsFixed(1)}%';
  }
}
