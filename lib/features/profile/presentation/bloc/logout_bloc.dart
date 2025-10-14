//EVENTOS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/profile/domain/usecases/logout_usecase.dart';

abstract class LogoutEvent {}

class SubmitLogoutEvent extends LogoutEvent {}

//ESTADOS
abstract class LogoutState {}

class LogoutIdle extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutError extends LogoutState {
  final String message;
  LogoutError(this.message);
}

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutUsecase logoutUsecase = LogoutUsecase();
  LogoutBloc() : super(LogoutIdle()) {
    on<SubmitLogoutEvent>(_onSubmitLogout);
  }

  Future<void> _onSubmitLogout(
    SubmitLogoutEvent event,
    Emitter<LogoutState> emit,
  ) async {
    emit(LogoutLoading());
    try {
      await logoutUsecase.execute();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(e.toString()));
    }
  }
}
