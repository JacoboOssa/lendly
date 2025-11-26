import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_account_created_date_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_transactions_count_usecase.dart';

// EVENTS
abstract class ProfileDetailEvent {}

class LoadProfileDetail extends ProfileDetailEvent {
  final String userId;
  LoadProfileDetail(this.userId);
}

// STATES
abstract class ProfileDetailState {}

class ProfileDetailInitial extends ProfileDetailState {}

class ProfileDetailLoading extends ProfileDetailState {}

class ProfileDetailLoaded extends ProfileDetailState {
  final AppUser user;
  final DateTime? accountCreatedDate;
  final int transactionsCount;

  ProfileDetailLoaded({
    required this.user,
    this.accountCreatedDate,
    required this.transactionsCount,
  });
}

class ProfileDetailError extends ProfileDetailState {
  final String message;
  ProfileDetailError(this.message);
}

// BLOC
class ProfileDetailBloc extends Bloc<ProfileDetailEvent, ProfileDetailState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserAccountCreatedDateUseCase getAccountCreatedDateUseCase;
  final GetUserTransactionsCountUseCase getTransactionsCountUseCase;

  ProfileDetailBloc({
    required this.getUserProfileUseCase,
    required this.getAccountCreatedDateUseCase,
    required this.getTransactionsCountUseCase,
  }) : super(ProfileDetailInitial()) {
    on<LoadProfileDetail>(_onLoadProfileDetail);
  }

  Future<void> _onLoadProfileDetail(
    LoadProfileDetail event,
    Emitter<ProfileDetailState> emit,
  ) async {
    emit(ProfileDetailLoading());

    try {
      final user = await getUserProfileUseCase.execute(event.userId);
      
      if (user == null) {
        emit(ProfileDetailError('Usuario no encontrado'));
        return;
      }

      // Obtener fecha de creación de cuenta
      final accountCreatedDate = await getAccountCreatedDateUseCase.execute(event.userId);
      
      // Obtener cantidad de transacciones según el rol
      final transactionsCount = await getTransactionsCountUseCase.execute(
        event.userId,
        user.role,
      );

      emit(ProfileDetailLoaded(
        user: user,
        accountCreatedDate: accountCreatedDate,
        transactionsCount: transactionsCount,
      ));
    } catch (e) {
      emit(ProfileDetailError('Error al cargar el perfil: ${e.toString()}'));
    }
  }
}

