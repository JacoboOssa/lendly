//EVENTOS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

abstract class GetCurrentUserEvent {}

class GetCurrentUser extends GetCurrentUserEvent {}

//ESTADOS
abstract class GetCurrentUserState {}

class GetCurrentUserIdle extends GetCurrentUserState {}

class GetCurrentUserLoading extends GetCurrentUserState {}

class GetCurrentUserSuccess extends GetCurrentUserState {
  final AppUser user;
  GetCurrentUserSuccess(this.user);
}

class GetCurrentUserError extends GetCurrentUserState {
  final String message;
  GetCurrentUserError(this.message);
}

class GetCurrentUserBloc
    extends Bloc<GetCurrentUserEvent, GetCurrentUserState> {
  final GetCurrentUserUsecase getCurrentUserUsecase = GetCurrentUserUsecase();

  GetCurrentUserBloc() : super(GetCurrentUserIdle()) {
    on<GetCurrentUser>(_onGetCurrentUser);
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<GetCurrentUserState> emit,
  ) async {
    emit(GetCurrentUserLoading());
    try {
      final user = await getCurrentUserUsecase.execute();
      if (user != null) {
        emit(GetCurrentUserSuccess(user));
      } else {
        emit(GetCurrentUserError("No user found"));
      }
    } catch (e) {
      emit(GetCurrentUserError(e.toString()));
    }
  }
}
