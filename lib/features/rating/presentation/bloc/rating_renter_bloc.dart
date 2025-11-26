import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/create_borrower_rating_usecase.dart';

// Events
abstract class RatingRenterEvent {}

class SubmitBorrowerRatingEvent extends RatingRenterEvent {
  final String rentalId;
  final String borrowerUserId;
  final int rating;
  final String? comment;

  SubmitBorrowerRatingEvent({
    required this.rentalId,
    required this.borrowerUserId,
    required this.rating,
    this.comment,
  });
}

// States
abstract class RatingRenterState {}

class RatingRenterInitial extends RatingRenterState {}

class RatingRenterLoading extends RatingRenterState {}

class RatingRenterSuccess extends RatingRenterState {}

class RatingRenterError extends RatingRenterState {
  final String message;

  RatingRenterError(this.message);
}

// Bloc
class RatingRenterBloc extends Bloc<RatingRenterEvent, RatingRenterState> {
  final CreateBorrowerRatingUseCase createBorrowerRatingUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RatingRenterBloc({
    CreateBorrowerRatingUseCase? createBorrowerRatingUseCase,
    GetCurrentUserIdUseCase? getCurrentUserIdUseCase,
  })  : createBorrowerRatingUseCase =
            createBorrowerRatingUseCase ?? CreateBorrowerRatingUseCase(),
        getCurrentUserIdUseCase = getCurrentUserIdUseCase ?? GetCurrentUserIdUseCase(),
        super(RatingRenterInitial()) {
    on<SubmitBorrowerRatingEvent>(_onSubmitRating);
  }

  Future<void> _onSubmitRating(
    SubmitBorrowerRatingEvent event,
    Emitter<RatingRenterState> emit,
  ) async {
    emit(RatingRenterLoading());

    try {
      final raterUserId = await getCurrentUserIdUseCase.execute();
      if (raterUserId == null) {
        emit(RatingRenterError('Usuario no encontrado'));
        return;
      }

      await createBorrowerRatingUseCase.execute(
        rentalId: event.rentalId,
        raterUserId: raterUserId,
        borrowerUserId: event.borrowerUserId,
        rating: event.rating,
        comment: event.comment,
      );

      emit(RatingRenterSuccess());
    } catch (e) {
      emit(RatingRenterError('Error al guardar la calificación: ${e.toString()}'));
    }
  }
}

