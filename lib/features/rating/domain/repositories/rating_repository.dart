import 'package:lendly_app/domain/model/rating.dart';

abstract class RatingRepository {
  Future<Rating> createRating(Rating rating);
  Future<List<Rating>> getRatingsByRentalId(String rentalId);
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type});
  Future<List<Rating>> getRatingsByProductId(String productId);
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type);
}

