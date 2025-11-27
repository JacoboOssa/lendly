//EVENTOS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/checkout/domain/usecases/update_payment_status_usecase.dart';

abstract class CheckoutEvent {}

class ProcessPaymentEvent extends CheckoutEvent {
  final String paymentId;

  ProcessPaymentEvent(this.paymentId);
}

//ESTADOS
abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}

//BLOC
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final UpdatePaymentStatusUseCase updatePaymentStatusUseCase =
      UpdatePaymentStatusUseCase();

  CheckoutBloc() : super(CheckoutInitial()) {
    on<ProcessPaymentEvent>(_onProcessPayment);
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      await updatePaymentStatusUseCase.execute(event.paymentId, true);
      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}

