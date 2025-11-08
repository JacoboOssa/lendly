import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/home/domain/usecases/get_user_role_usecase.dart';

// EVENTOS
abstract class GetUserRoleEvent {}

class GetUserRole extends GetUserRoleEvent {}

// ESTADOS
abstract class GetUserRoleState {}

class GetUserRoleIdle extends GetUserRoleState {}

class GetUserRoleLoading extends GetUserRoleState {}

class GetUserRoleSuccess extends GetUserRoleState {
  final String role;
  GetUserRoleSuccess(this.role);
}

class GetUserRoleError extends GetUserRoleState {
  final String message;
  GetUserRoleError(this.message);
}

// BLOC
class GetUserRoleBloc extends Bloc<GetUserRoleEvent, GetUserRoleState> {
  final GetUserRoleUseCase getUserRoleUseCase = GetUserRoleUseCase();

  GetUserRoleBloc() : super(GetUserRoleIdle()) {
    on<GetUserRole>(_onGetUserRole);
  }

  Future<void> _onGetUserRole(
    GetUserRole event,
    Emitter<GetUserRoleState> emit,
  ) async {
    emit(GetUserRoleLoading());
    try {
      final role = await getUserRoleUseCase.execute();
      if (role != null) {
        emit(GetUserRoleSuccess(role));
      } else {
        emit(GetUserRoleError("No role found"));
      }
    } catch (e) {
      emit(GetUserRoleError(e.toString()));
    }
  }
}
