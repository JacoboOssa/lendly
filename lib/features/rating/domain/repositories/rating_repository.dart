import 'package:lendly_app/domain/model/rating.dart';

abstract class RatingRepository {
  Future<Rating> createRating(Rating rating);
  Future<List<Rating>> getRatingsByRentalId(String rentalId);
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type});
  Future<List<Rating>> getRatingsByProductId(String productId);
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type);
  
  // Paginated methods
  Future<List<Rating>> getRatingsByUserIdPaginated(
    String userId, {
    RatingType? type,
    int page = 0,
    int pageSize = 10,
  });
  Future<List<Rating>> getRatingsByProductIdPaginated(
    String productId, {
    int page = 0,
    int pageSize = 10,
  });
  
  // Average rating methods
  Future<double?> getUserAverageRating(String userId, {RatingType? type});
  Future<double?> getProductAverageRating(String productId);
}

