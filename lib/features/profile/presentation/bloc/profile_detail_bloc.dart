import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_account_created_date_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_transactions_count_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/get_user_average_rating_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/get_user_ratings_paginated_usecase.dart';

// EVENTS
abstract class ProfileDetailEvent {}

class LoadProfileDetail extends ProfileDetailEvent {
  final String userId;
  LoadProfileDetail(this.userId);
}

class LoadMoreRatings extends ProfileDetailEvent {}

// STATES
abstract class ProfileDetailState {}

class ProfileDetailInitial extends ProfileDetailState {}

class ProfileDetailLoading extends ProfileDetailState {}

class ProfileDetailLoaded extends ProfileDetailState {
  final AppUser user;
  final DateTime? accountCreatedDate;
  final int transactionsCount;
  final double? averageRating;
  final List<Rating> ratings;
  final int currentPage;
  final bool hasMoreRatings;
  final bool isLoadingMoreRatings;

  ProfileDetailLoaded({
    required this.user,
    this.accountCreatedDate,
    required this.transactionsCount,
    this.averageRating,
    this.ratings = const [],
    this.currentPage = 0,
    this.hasMoreRatings = true,
    this.isLoadingMoreRatings = false,
  });

  ProfileDetailLoaded copyWith({
    AppUser? user,
    DateTime? accountCreatedDate,
    int? transactionsCount,
    double? averageRating,
    List<Rating>? ratings,
    int? currentPage,
    bool? hasMoreRatings,
    bool? isLoadingMoreRatings,
  }) {
    return ProfileDetailLoaded(
      user: user ?? this.user,
      accountCreatedDate: accountCreatedDate ?? this.accountCreatedDate,
      transactionsCount: transactionsCount ?? this.transactionsCount,
      averageRating: averageRating ?? this.averageRating,
      ratings: ratings ?? this.ratings,
      currentPage: currentPage ?? this.currentPage,
      hasMoreRatings: hasMoreRatings ?? this.hasMoreRatings,
      isLoadingMoreRatings: isLoadingMoreRatings ?? this.isLoadingMoreRatings,
    );
  }
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
  final GetUserAverageRatingUseCase getUserAverageRatingUseCase;
  final GetUserRatingsPaginatedUseCase getUserRatingsPaginatedUseCase;

  static const int pageSize = 10;

  ProfileDetailBloc({
    required this.getUserProfileUseCase,
    required this.getAccountCreatedDateUseCase,
    required this.getTransactionsCountUseCase,
    GetUserAverageRatingUseCase? getUserAverageRatingUseCase,
    GetUserRatingsPaginatedUseCase? getUserRatingsPaginatedUseCase,
  })  : getUserAverageRatingUseCase = getUserAverageRatingUseCase ?? GetUserAverageRatingUseCase(),
        getUserRatingsPaginatedUseCase = getUserRatingsPaginatedUseCase ?? GetUserRatingsPaginatedUseCase(),
        super(ProfileDetailInitial()) {
    on<LoadProfileDetail>(_onLoadProfileDetail);
    on<LoadMoreRatings>(_onLoadMoreRatings);
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

      // Obtener promedio de calificaciones (para owner y borrower)
      final averageRating = await getUserAverageRatingUseCase.execute(userId: event.userId);

      // Cargar primera página de ratings
      final ratings = await getUserRatingsPaginatedUseCase.execute(
        userId: event.userId,
        page: 0,
        pageSize: pageSize,
      );

      emit(ProfileDetailLoaded(
        user: user,
        accountCreatedDate: accountCreatedDate,
        transactionsCount: transactionsCount,
        averageRating: averageRating,
        ratings: ratings,
        currentPage: 0,
        hasMoreRatings: ratings.length >= pageSize,
      ));
    } catch (e) {
      emit(ProfileDetailError('Error al cargar el perfil: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreRatings(
    LoadMoreRatings event,
    Emitter<ProfileDetailState> emit,
  ) async {
    if (state is! ProfileDetailLoaded) return;
    final currentState = state as ProfileDetailLoaded;

    if (!currentState.hasMoreRatings || currentState.isLoadingMoreRatings) return;

    emit(currentState.copyWith(isLoadingMoreRatings: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newRatings = await getUserRatingsPaginatedUseCase.execute(
        userId: currentState.user.id,
        page: nextPage,
        pageSize: pageSize,
      );

      final allRatings = [...currentState.ratings, ...newRatings];
      final hasMore = newRatings.length >= pageSize;

      emit(currentState.copyWith(
        ratings: allRatings,
        currentPage: nextPage,
        hasMoreRatings: hasMore,
        isLoadingMoreRatings: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreRatings: false));
    }
  }
}

