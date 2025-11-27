import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/return.dart';
import 'package:lendly_app/features/return/domain/usecases/create_return_usecase.dart';

// Events
abstract class ReturnEvent {}

class CreateReturnEvent extends ReturnEvent {
  final String rentalId;
  final TimeOfDay proposedReturnTime;
  final String? note;

  CreateReturnEvent({
    required this.rentalId,
    required this.proposedReturnTime,
    this.note,
  });
}

// States
abstract class ReturnState {}

class ReturnInitial extends ReturnState {}

class ReturnLoading extends ReturnState {}

class ReturnSuccess extends ReturnState {
  final Return returnData;

  ReturnSuccess(this.returnData);
}

class ReturnError extends ReturnState {
  final String message;

  ReturnError(this.message);
}

// Bloc
class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  late final CreateReturnUseCase createReturnUseCase;

  ReturnBloc() : super(ReturnInitial()) {
    // El BLoC solo instancia use cases, los use cases instancian los repositories
    createReturnUseCase = CreateReturnUseCase();

    on<CreateReturnEvent>(_onCreateReturn);
  }

  Future<void> _onCreateReturn(
    CreateReturnEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(ReturnLoading());

    try {
      final returnData = await createReturnUseCase.execute(
        rentalId: event.rentalId,
        proposedReturnTime: event.proposedReturnTime,
        note: event.note,
      );

      emit(ReturnSuccess(returnData));
    } catch (e) {
      emit(ReturnError('Error al procesar la devolución: ${e.toString()}'));
    }
  }
}

