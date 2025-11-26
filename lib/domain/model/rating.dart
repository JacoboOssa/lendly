enum RatingType {
  owner,
  product,
  borrower,
}

class Rating {
  final String? id;
  final String rentalId;
  final String raterUserId;
  final RatingType ratingType;
  final String? ratedUserId; // Para owner o borrower
  final String? productId; // Para product
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Rating({
    this.id,
    required this.rentalId,
    required this.raterUserId,
    required this.ratingType,
    this.ratedUserId,
    this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rental_id': rentalId,
      'rater_user_id': raterUserId,
      'rating_type': ratingTypeToDbString(ratingType),
      if (ratedUserId != null) 'rated_user_id': ratedUserId,
      if (productId != null) 'product_id': productId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      rentalId: json['rental_id'],
      raterUserId: json['rater_user_id'],
      ratingType: ratingTypeFromDbString(json['rating_type']),
      ratedUserId: json['rated_user_id'],
      productId: json['product_id'],
      rating: json['rating'] as int,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String ratingTypeToDbString(RatingType type) {
    switch (type) {
      case RatingType.owner:
        return 'owner';
      case RatingType.product:
        return 'product';
      case RatingType.borrower:
        return 'borrower';
    }
  }

  static RatingType ratingTypeFromDbString(String type) {
    switch (type.toLowerCase()) {
      case 'owner':
        return RatingType.owner;
      case 'product':
        return RatingType.product;
      case 'borrower':
        return RatingType.borrower;
      default:
        throw ArgumentError('Invalid rating type: $type');
    }
  }
}

