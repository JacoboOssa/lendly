import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/auth/domain/usecases/register_user_usecase.dart';

//EVENTOS
//Listo todas las acciones que mi usuario puede hacer dentro de la screen/page
// ***********************************
abstract class RegisterEvent {}

class SubmitRegisterEvent extends RegisterEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  final String phone;
  final String address;
  final String city;

  SubmitRegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.phone,
    required this.address,
    required this.city,
  });
}
// ***********************************

//ESTADOS
//Listo todos los estados que mi screen/page puede tener
// -----------------------------------
abstract class RegisterState {}

class RegisterIdle extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}
// -----------------------------------

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUseCase registerUserUseCase = RegisterUserUseCase();

  RegisterBloc() : super(RegisterIdle()) {
    on<SubmitRegisterEvent>(_onSubmitRegister);
  }

  Future<void> _onSubmitRegister(
    SubmitRegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await registerUserUseCase.execute(
        event.email,
        event.password,
        AppUser(
          id: '',
          name: event.name,
          role: event.role,
          phone: event.phone,
          address: event.address,
          city: event.city,
        ),
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterError("No se pudo registrar el usuario"));
    }
  }
}
