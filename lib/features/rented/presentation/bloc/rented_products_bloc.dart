import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rented/domain/usecases/get_rented_products_usecase.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class RentedProductsEvent {}

class LoadRentedProductsEvent extends RentedProductsEvent {}

// States
abstract class RentedProductsState {}

class RentedProductsInitial extends RentedProductsState {}

class RentedProductsLoading extends RentedProductsState {}

class RentedProductsLoaded extends RentedProductsState {
  final List<RentedProductData> products;
  final bool isBorrower;

  RentedProductsLoaded({
    required this.products,
    required this.isBorrower,
  });
}

class RentedProductsError extends RentedProductsState {
  final String message;

  RentedProductsError(this.message);
}

// Bloc
class RentedProductsBloc extends Bloc<RentedProductsEvent, RentedProductsState> {
  final GetRentedProductsUseCase getRentedProductsUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RentedProductsBloc({
    GetRentedProductsUseCase? getRentedProductsUseCase,
    GetCurrentUserUsecase? getCurrentUserUsecase,
    GetCurrentUserIdUseCase? getCurrentUserIdUseCase,
  })  :         getRentedProductsUseCase = getRentedProductsUseCase ?? GetRentedProductsUseCase(),
        getCurrentUserUsecase = getCurrentUserUsecase ?? GetCurrentUserUsecase(),
        getCurrentUserIdUseCase = getCurrentUserIdUseCase ?? GetCurrentUserIdUseCase(),
        super(RentedProductsInitial()) {
    on<LoadRentedProductsEvent>(_onLoadRentedProducts);
  }

  Future<void> _onLoadRentedProducts(
    LoadRentedProductsEvent event,
    Emitter<RentedProductsState> emit,
  ) async {
    emit(RentedProductsLoading());

    try {
      final currentUser = await getCurrentUserUsecase.execute();
      if (currentUser == null) {
        emit(RentedProductsError("Usuario actual no encontrado"));
        return;
      }

      final isBorrower = currentUser.role.toLowerCase() == 'borrower';
      final userId = currentUser.id;

      final products = isBorrower
          ? await getRentedProductsUseCase.executeForBorrower(userId)
          : await getRentedProductsUseCase.executeForLender(userId);

      emit(RentedProductsLoaded(
        products: products,
        isBorrower: isBorrower,
      ));
    } catch (e) {
      emit(RentedProductsError("Error al cargar productos alquilados: ${e.toString()}"));
    }
  }
}

