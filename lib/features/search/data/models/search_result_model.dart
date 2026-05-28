class SearchShopInfo {
  final int id;
  final String name;
  final String? address;

  const SearchShopInfo({required this.id, required this.name, this.address});

  factory SearchShopInfo.fromJson(Map<String, dynamic> json) => SearchShopInfo(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
      );
}

class SearchResultItem {
  final String type;
  final int id;
  final String name;
  final double price;
  final double? rating;
  final int ratingCount;
  final bool isAvailable;
  final SearchShopInfo shop;
  final String? imageUrl;

  const SearchResultItem({
    required this.type,
    required this.id,
    required this.name,
    required this.price,
    this.rating,
    required this.ratingCount,
    required this.isAvailable,
    required this.shop,
    this.imageUrl,
  });

  bool get isProduct => type == 'product';
  bool get isService => type == 'service';

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      SearchResultItem(
        type: json['type'] as String? ?? 'product',
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        rating:
            json['rating'] != null ? (json['rating'] as num).toDouble() : null,
        ratingCount: json['rating_count'] as int? ?? 0,
        isAvailable: json['is_available'] as bool? ?? true,
        shop: SearchShopInfo.fromJson(
            (json['shop'] as Map<String, dynamic>?) ?? {}),
        imageUrl: json['image_url'] as String?,
      );
}

class SearchResponse {
  final List<SearchResultItem> items;
  final int total;
  final int page;
  final int limit;

  const SearchResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
        items: (json['items'] as List? ?? [])
            .map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 20,
      );
}
