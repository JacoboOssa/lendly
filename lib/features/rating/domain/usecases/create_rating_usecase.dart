import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';

class CreateRatingUseCase {
  final RatingRepository repository;

  CreateRatingUseCase() : repository = RatingRepositoryImpl();

  Future<Rating> execute({
    required String rentalId,
    required String raterUserId,
    required RatingType ratingType,
    String? ratedUserId,
    String? productId,
    required int rating,
    String? comment,
  }) async {
    final ratingData = Rating(
      rentalId: rentalId,
      raterUserId: raterUserId,
      ratingType: ratingType,
      ratedUserId: ratedUserId,
      productId: productId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    return await repository.createRating(ratingData);
  }
}

