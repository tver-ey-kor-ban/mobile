import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import '../../../core/network/api_constants.dart';
import '../../shop/data/models/browse_models.dart';

/// Service for image-based product search
class ImageSearchService {
  final http.Client _client;

  ImageSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Search products by uploading an image to a specific shop
  Future<ImageSearchResult> searchByImage(
    File imageFile,
    int shopId, {
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.apiVersion}/search/image?shop_id=$shopId');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Determine mimetype based on file extension
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'webp') {
        mimeType = 'image/webp';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ImageSearchResult.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to perform image search. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Image search request failed: $e');
    }
  }

  /// Search products with additional text query combined with image (optional endpoint)
  Future<ImageSearchResult> searchByImageAndText(
    File imageFile,
    int shopId,
    String textQuery, {
    int limit = 10,
  }) async {
    // For now, we reuse the same image search endpoint and filter/search results on client
    final result = await searchByImage(imageFile, shopId, limit: limit);
    if (textQuery.trim().isEmpty) {
      return result;
    }
    
    final filteredProducts = result.products
        .where((p) =>
            p.name.toLowerCase().contains(textQuery.toLowerCase()) ||
            (p.category != null && p.category!.toLowerCase().contains(textQuery.toLowerCase())))
        .toList();

    return ImageSearchResult(
      products: filteredProducts,
      totalResults: filteredProducts.length,
      searchId: result.searchId,
      message: result.message,
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

  /// Convert to standard ShopProduct model for details sheet integration
  ShopProduct toShopProduct() {
    return ShopProduct(
      id: id,
      name: name,
      description: description,
      price: price ?? 0.0,
      currency: currency,
      category: category,
      brand: brand,
      isAvailable: additionalData?['is_active'] ?? additionalData?['is_available'] ?? true,
      stockQuantity: additionalData?['stock_quantity'],
      rating: additionalData?['rating'] != null ? (additionalData!['rating'] as num).toDouble() : null,
      ratingCount: additionalData?['rating_count'],
      imageUrl: imageUrl,
    );
  }
}
