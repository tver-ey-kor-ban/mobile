/// Model for creating a rating
class RatingRequest {
  final int rating;
  final String? comment;

  RatingRequest({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}

/// Model for rating response
class RatingResponse {
  final int id;
  final int rating;
  final String? comment;
  final String? createdAt;
  final RatingUser? user;

  RatingResponse({
    required this.id,
    required this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'],
      user: json['user'] != null ? RatingUser.fromJson(json['user']) : null,
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
    final ratingsList = json['ratings'] ?? json['data'] ?? json['items'] ?? [];
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
