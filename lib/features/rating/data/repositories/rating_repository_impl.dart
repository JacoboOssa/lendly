import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/source/rating_data_source.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingDataSource dataSource;

  RatingRepositoryImpl(this.dataSource);

  @override
  Future<Rating> createRating(Rating rating) {
    return dataSource.createRating(rating);
  }

  @override
  Future<List<Rating>> getRatingsByRentalId(String rentalId) {
    return dataSource.getRatingsByRentalId(rentalId);
  }

  @override
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type}) {
    return dataSource.getRatingsByUserId(userId, type: type);
  }

  @override
  Future<List<Rating>> getRatingsByProductId(String productId) {
    return dataSource.getRatingsByProductId(productId);
  }

  @override
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type) {
    return dataSource.getRatingByRentalAndType(rentalId, raterUserId, type);
  }
}

