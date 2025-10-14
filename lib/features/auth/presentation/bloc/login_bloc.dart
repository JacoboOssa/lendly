//EVENTOS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/auth/domain/usecases/sign_in_usecase.dart';

abstract class LoginEvent {}

class SubmitLoginEvent extends LoginEvent {
  final String email;
  final String password;

  SubmitLoginEvent({required this.email, required this.password});
}

//ESTADOS
abstract class LoginState {}

class LoginIdle extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUsecase signInUsecase = SignInUsecase();

  LoginBloc() : super(LoginIdle()) {
    on<SubmitLoginEvent>(_onSubmitLogin);
  }

  Future<void> _onSubmitLogin(
    SubmitLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await signInUsecase.execute(event.email, event.password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
