/// Model for rating a product
class ProductRatingRequest {
  final int productId;
  final int rating;
  final String? review;
  final int? orderId;

  ProductRatingRequest({
    required this.productId,
    required this.rating,
    this.review,
    this.orderId,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'rating': rating,
        if (review != null) 'review': review,
        if (orderId != null) 'order_id': orderId,
      };
}

/// Model for rating a service
class ServiceRatingRequest {
  final int serviceId;
  final int rating;
  final String? review;
  final int? appointmentId;

  ServiceRatingRequest({
    required this.serviceId,
    required this.rating,
    this.review,
    this.appointmentId,
  });

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'rating': rating,
        if (review != null) 'review': review,
        if (appointmentId != null) 'appointment_id': appointmentId,
      };
}

/// Model for rating a mechanic
class MechanicRatingRequest {
  final int appointmentId;
  final int rating;
  final String? review;

  MechanicRatingRequest({
    required this.appointmentId,
    required this.rating,
    this.review,
  });

  Map<String, dynamic> toJson() => {
        'appointment_id': appointmentId,
        'rating': rating,
        if (review != null) 'review': review,
      };
}

/// Model for rating response
class RatingResponse {
  final int id;
  final int rating;
  final String? review;
  final String? createdAt;
  final RatingUser? user;

  RatingResponse({
    required this.id,
    required this.rating,
    this.review,
    this.createdAt,
    this.user,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'],
      createdAt: json['created_at'],
      user: json['user'] != null ? RatingUser.fromJson(json['user']) : null,
    );
  }
}

/// Model for rating summary
class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] ?? 0,
      fiveStar: json['five_star'] ?? 0,
      fourStar: json['four_star'] ?? 0,
      threeStar: json['three_star'] ?? 0,
      twoStar: json['two_star'] ?? 0,
      oneStar: json['one_star'] ?? 0,
    );
  }
}

/// Model for rating user info
class RatingUser {
  final int id;
  final String fullName;
  final String? avatarUrl;

  RatingUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory RatingUser.fromJson(Map<String, dynamic> json) {
    return RatingUser(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Anonymous',
      avatarUrl: json['avatar_url'],
    );
  }
}

/// Model for paginated ratings list
class RatingsListResponse {
  final List<RatingResponse> ratings;
  final int total;
  final int page;
  final int limit;
  final double? averageRating;

  RatingsListResponse({
    required this.ratings,
    required this.total,
    required this.page,
    required this.limit,
    this.averageRating,
  });

  factory RatingsListResponse.fromJson(Map<String, dynamic> json) {
    final ratingsList = json['items'] ?? json['ratings'] ?? json['data'] ?? [];
    return RatingsListResponse(
      ratings: (ratingsList as List)
          .map((item) => RatingResponse.fromJson(item))
          .toList(),
      total: json['total'] ?? json['total_count'] ?? 0,
      page: json['page'] ?? json['current_page'] ?? 1,
      limit: json['limit'] ?? json['per_page'] ?? 10,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
    );
  }
}
