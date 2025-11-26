import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/data/source/rating_data_source.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class GetProductRatingsPaginatedUseCase {
  final RatingRepository repository = RatingRepositoryImpl(RatingDataSourceImpl());

  Future<List<Rating>> execute({
    required String productId,
    int page = 0,
    int pageSize = 10,
  }) {
    return repository.getRatingsByProductIdPaginated(
      productId,
      page: page,
      pageSize: pageSize,
    );
  }
}

