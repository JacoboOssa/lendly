import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class GetUserRatingsPaginatedUseCase {
  final RatingRepository repository = RatingRepositoryImpl();

  Future<List<Rating>> execute({
    required String userId,
    RatingType? type,
    int page = 0,
    int pageSize = 10,
  }) {
    return repository.getRatingsByUserIdPaginated(
      userId,
      type: type,
      page: page,
      pageSize: pageSize,
    );
  }
}

