import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/rating/domain/usecases/create_rating_usecase.dart';

class CreateBorrowerRatingUseCase {
  final CreateRatingUseCase createRatingUseCase;

  CreateBorrowerRatingUseCase({
    CreateRatingUseCase? createRatingUseCase,
  }) : createRatingUseCase = createRatingUseCase ?? CreateRatingUseCase();

  Future<void> execute({
    required String rentalId,
    required String raterUserId,
    required String borrowerUserId,
    required int rating,
    String? comment,
  }) async {
    await createRatingUseCase.execute(
      rentalId: rentalId,
      raterUserId: raterUserId,
      ratingType: RatingType.borrower,
      ratedUserId: borrowerUserId,
      rating: rating,
      comment: comment,
    );
  }
}

