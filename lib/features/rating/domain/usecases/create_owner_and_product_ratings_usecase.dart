import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/domain/usecases/create_rating_usecase.dart';

class CreateOwnerAndProductRatingsUseCase {
  final CreateRatingUseCase createRatingUseCase;

  CreateOwnerAndProductRatingsUseCase({
    CreateRatingUseCase? createRatingUseCase,
  }) : createRatingUseCase = createRatingUseCase ?? CreateRatingUseCase();

  Future<void> execute({
    required String rentalId,
    required String raterUserId,
    required String ownerUserId,
    required String productId,
    required int ownerRating,
    String? ownerComment,
    required int productRating,
    String? productComment,
  }) async {
    // Crear calificación del dueño
    await createRatingUseCase.execute(
      rentalId: rentalId,
      raterUserId: raterUserId,
      ratingType: RatingType.owner,
      ratedUserId: ownerUserId,
      rating: ownerRating,
      comment: ownerComment,
    );

    // Crear calificación del producto
    await createRatingUseCase.execute(
      rentalId: rentalId,
      raterUserId: raterUserId,
      ratingType: RatingType.product,
      productId: productId,
      rating: productRating,
      comment: productComment,
    );
  }
}

