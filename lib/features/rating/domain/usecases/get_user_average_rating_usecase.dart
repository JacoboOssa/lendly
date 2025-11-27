import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class GetUserAverageRatingUseCase {
  final RatingRepository repository = RatingRepositoryImpl();

  Future<double?> execute({
    required String userId,
    RatingType? type,
  }) {
    return repository.getUserAverageRating(userId, type: type);
  }
}

