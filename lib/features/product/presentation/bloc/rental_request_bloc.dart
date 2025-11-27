import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/create_rental_request_usecase.dart';

// EVENTS
abstract class RentalRequestEvent {}

class CreateRentalRequest extends RentalRequestEvent {
  final String productId;
  final DateTime startDate;
  final DateTime endDate;

  CreateRentalRequest({
    required this.productId,
    required this.startDate,
    required this.endDate,
  });
}

// STATES
abstract class RentalRequestState {}

class RentalRequestInitial extends RentalRequestState {}

class RentalRequestLoading extends RentalRequestState {}

class RentalRequestSuccess extends RentalRequestState {
  final RentalRequest request;

  RentalRequestSuccess(this.request);
}

class RentalRequestError extends RentalRequestState {
  final String message;

  RentalRequestError(this.message);
}

// BLOC
class RentalRequestBloc extends Bloc<RentalRequestEvent, RentalRequestState> {
  late final CreateRentalRequestUseCase createRentalRequestUseCase;
  late final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RentalRequestBloc() : super(RentalRequestInitial()) {
    // El BLoC solo instancia use cases, los use cases instancian los repositories
    createRentalRequestUseCase = CreateRentalRequestUseCase();
    getCurrentUserIdUseCase = GetCurrentUserIdUseCase();
    
    on<CreateRentalRequest>(_onCreateRentalRequest);
  }

  Future<void> _onCreateRentalRequest(
    CreateRentalRequest event,
    Emitter<RentalRequestState> emit,
  ) async {
    emit(RentalRequestLoading());

    try {
      final userId = await getCurrentUserIdUseCase.execute();
      if (userId == null) {
        emit(RentalRequestError('Debes iniciar sesión para solicitar un alquiler'));
        return;
      }

      final now = DateTime.now();
      final request = RentalRequest(
        productId: event.productId,
        borrowerUserId: userId,
        startDate: event.startDate,
        endDate: event.endDate,
        status: RentalRequestStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final createdRequest = await createRentalRequestUseCase.execute(request);

      emit(RentalRequestSuccess(createdRequest));
    } catch (e) {
      emit(RentalRequestError('Error al crear la solicitud: ${e.toString()}'));
    }
  }
}

