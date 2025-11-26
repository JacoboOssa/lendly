import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/create_owner_and_product_ratings_usecase.dart';

// Events
abstract class RatingOwnerProductEvent {}

class SubmitOwnerAndProductRatingsEvent extends RatingOwnerProductEvent {
  final String rentalId;
  final String ownerUserId;
  final String productId;
  final int ownerRating;
  final String? ownerComment;
  final int productRating;
  final String? productComment;

  SubmitOwnerAndProductRatingsEvent({
    required this.rentalId,
    required this.ownerUserId,
    required this.productId,
    required this.ownerRating,
    this.ownerComment,
    required this.productRating,
    this.productComment,
  });
}

// States
abstract class RatingOwnerProductState {}

class RatingOwnerProductInitial extends RatingOwnerProductState {}

class RatingOwnerProductLoading extends RatingOwnerProductState {}

class RatingOwnerProductSuccess extends RatingOwnerProductState {}

class RatingOwnerProductError extends RatingOwnerProductState {
  final String message;

  RatingOwnerProductError(this.message);
}

// Bloc
class RatingOwnerProductBloc extends Bloc<RatingOwnerProductEvent, RatingOwnerProductState> {
  final CreateOwnerAndProductRatingsUseCase createOwnerAndProductRatingsUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RatingOwnerProductBloc({
    CreateOwnerAndProductRatingsUseCase? createOwnerAndProductRatingsUseCase,
    GetCurrentUserIdUseCase? getCurrentUserIdUseCase,
  })  : createOwnerAndProductRatingsUseCase =
            createOwnerAndProductRatingsUseCase ?? CreateOwnerAndProductRatingsUseCase(),
        getCurrentUserIdUseCase = getCurrentUserIdUseCase ?? GetCurrentUserIdUseCase(),
        super(RatingOwnerProductInitial()) {
    on<SubmitOwnerAndProductRatingsEvent>(_onSubmitRatings);
  }

  Future<void> _onSubmitRatings(
    SubmitOwnerAndProductRatingsEvent event,
    Emitter<RatingOwnerProductState> emit,
  ) async {
    emit(RatingOwnerProductLoading());

    try {
      final raterUserId = await getCurrentUserIdUseCase.execute();
      if (raterUserId == null) {
        emit(RatingOwnerProductError('Usuario no encontrado'));
        return;
      }

      await createOwnerAndProductRatingsUseCase.execute(
        rentalId: event.rentalId,
        raterUserId: raterUserId,
        ownerUserId: event.ownerUserId,
        productId: event.productId,
        ownerRating: event.ownerRating,
        ownerComment: event.ownerComment,
        productRating: event.productRating,
        productComment: event.productComment,
      );

      emit(RatingOwnerProductSuccess());
    } catch (e) {
      emit(RatingOwnerProductError('Error al guardar las calificaciones: ${e.toString()}'));
    }
  }
}

