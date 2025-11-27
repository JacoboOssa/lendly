import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rented/domain/usecases/get_rented_products_usecase.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class RentedProductsEvent {}

class LoadRentedProductsEvent extends RentedProductsEvent {}

// States
abstract class RentedProductsState {
  final bool? isBorrower;
  RentedProductsState({this.isBorrower});
}

class RentedProductsInitial extends RentedProductsState {
  RentedProductsInitial() : super(isBorrower: null);
}

class RentedProductsRoleDetermined extends RentedProductsState {
  final bool isBorrower;
  RentedProductsRoleDetermined({required this.isBorrower}) : super(isBorrower: isBorrower);
}

class RentedProductsLoading extends RentedProductsState {
  final bool isBorrower;
  RentedProductsLoading({required this.isBorrower}) : super(isBorrower: isBorrower);
}

class RentedProductsLoaded extends RentedProductsState {
  final List<RentedProductData> products;
  final bool isBorrower;

  RentedProductsLoaded({
    required this.products,
    required this.isBorrower,
  }) : super(isBorrower: isBorrower);
}

class RentedProductsError extends RentedProductsState {
  final String message;

  RentedProductsError(this.message) : super(isBorrower: null);
}

// Bloc
class RentedProductsBloc extends Bloc<RentedProductsEvent, RentedProductsState> {
  late final GetRentedProductsUseCase getRentedProductsUseCase;
  late final GetCurrentUserUsecase getCurrentUserUsecase;
  late final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  RentedProductsBloc() : super(RentedProductsInitial()) {
    // El BLoC solo instancia use cases, los use cases instancian los repositories
    getRentedProductsUseCase = GetRentedProductsUseCase();
    getCurrentUserUsecase = GetCurrentUserUsecase();
    getCurrentUserIdUseCase = GetCurrentUserIdUseCase();
    
    on<LoadRentedProductsEvent>(_onLoadRentedProducts);
  }

  Future<void> _onLoadRentedProducts(
    LoadRentedProductsEvent event,
    Emitter<RentedProductsState> emit,
  ) async {
    try {
      final currentUser = await getCurrentUserUsecase.execute();
      if (currentUser == null) {
        emit(RentedProductsError("Usuario actual no encontrado"));
        return;
      }

      final isBorrower = currentUser.role.toLowerCase() == 'borrower';
      final userId = currentUser.id;

      // Emitir el rol inmediatamente para que el título se muestre correcto desde el inicio
      emit(RentedProductsRoleDetermined(isBorrower: isBorrower));
      
      emit(RentedProductsLoading(isBorrower: isBorrower));

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

