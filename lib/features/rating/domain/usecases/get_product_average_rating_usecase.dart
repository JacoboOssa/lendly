import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/data/source/rating_data_source.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class GetProductAverageRatingUseCase {
  final RatingRepository repository = RatingRepositoryImpl(RatingDataSourceImpl());

  Future<double?> execute(String productId) {
    return repository.getProductAverageRating(productId);
  }
}

