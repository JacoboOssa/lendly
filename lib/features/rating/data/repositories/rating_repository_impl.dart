import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/source/rating_data_source.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingDataSource dataSource;

  RatingRepositoryImpl() : dataSource = RatingDataSourceImpl();

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

  @override
  Future<List<Rating>> getRatingsByUserIdPaginated(
    String userId, {
    RatingType? type,
    int page = 0,
    int pageSize = 10,
  }) {
    return dataSource.getRatingsByUserIdPaginated(
      userId,
      type: type,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<Rating>> getRatingsByProductIdPaginated(
    String productId, {
    int page = 0,
    int pageSize = 10,
  }) {
    return dataSource.getRatingsByProductIdPaginated(
      productId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<double?> getUserAverageRating(String userId, {RatingType? type}) {
    return dataSource.getUserAverageRating(userId, type: type);
  }

  @override
  Future<double?> getProductAverageRating(String productId) {
    return dataSource.getProductAverageRating(productId);
  }
}

