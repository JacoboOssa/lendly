import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rental_history/domain/usecases/get_rental_history_usecase.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class RentalHistoryEvent {}

class LoadRentalHistoryEvent extends RentalHistoryEvent {}

// States
abstract class RentalHistoryState {
  final bool? isBorrower;
  RentalHistoryState({this.isBorrower});
}

class RentalHistoryInitial extends RentalHistoryState {
  RentalHistoryInitial() : super(isBorrower: null);
}

class RentalHistoryRoleDetermined extends RentalHistoryState {
  final bool isBorrower;
  RentalHistoryRoleDetermined({required this.isBorrower}) : super(isBorrower: isBorrower);
}

class RentalHistoryLoading extends RentalHistoryState {
  final bool isBorrower;
  RentalHistoryLoading({required this.isBorrower}) : super(isBorrower: isBorrower);
}

class RentalHistoryLoaded extends RentalHistoryState {
  final List<RentalHistoryData> rentals;
  final bool isBorrower;

  RentalHistoryLoaded({
    required this.rentals,
    required this.isBorrower,
  }) : super(isBorrower: isBorrower);
}

class RentalHistoryError extends RentalHistoryState {
  final String message;

  RentalHistoryError(this.message) : super(isBorrower: null);
}

// Bloc
class RentalHistoryBloc extends Bloc<RentalHistoryEvent, RentalHistoryState> {
  final GetRentalHistoryUseCase getRentalHistoryUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RentalHistoryBloc({
    GetRentalHistoryUseCase? getRentalHistoryUseCase,
    GetCurrentUserUsecase? getCurrentUserUsecase,
    GetCurrentUserIdUseCase? getCurrentUserIdUseCase,
  })  : getRentalHistoryUseCase =
            getRentalHistoryUseCase ?? GetRentalHistoryUseCase(),
        getCurrentUserUsecase = getCurrentUserUsecase ?? GetCurrentUserUsecase(),
        getCurrentUserIdUseCase =
            getCurrentUserIdUseCase ?? GetCurrentUserIdUseCase(),
        super(RentalHistoryInitial()) {
    on<LoadRentalHistoryEvent>(_onLoadRentalHistory);
  }

  Future<void> _onLoadRentalHistory(
    LoadRentalHistoryEvent event,
    Emitter<RentalHistoryState> emit,
  ) async {
    try {
      final currentUser = await getCurrentUserUsecase.execute();
      if (currentUser == null) {
        emit(RentalHistoryError("Usuario actual no encontrado"));
        return;
      }

      final isBorrower = currentUser.role.toLowerCase() == 'borrower';
      final userId = currentUser.id;

      // Emitir el rol inmediatamente para que el título se muestre correcto desde el inicio
      emit(RentalHistoryRoleDetermined(isBorrower: isBorrower));
      
      emit(RentalHistoryLoading(isBorrower: isBorrower));

      final rentals = isBorrower
          ? await getRentalHistoryUseCase.executeForBorrower(userId)
          : await getRentalHistoryUseCase.executeForLender(userId);

      emit(RentalHistoryLoaded(
        rentals: rentals,
        isBorrower: isBorrower,
      ));
    } catch (e) {
      emit(RentalHistoryError("Error al cargar historial de alquileres: ${e.toString()}"));
    }
  }
}

