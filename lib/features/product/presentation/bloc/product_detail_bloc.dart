import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/product/domain/usecases/get_owner_info_usecase.dart';

// EVENTS
abstract class ProductDetailEvent {}

class LoadProductDetail extends ProductDetailEvent {
  final Product product;
  LoadProductDetail(this.product);
}

// STATES
abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final Product product;
  final AppUser? owner;

  ProductDetailLoaded({required this.product, this.owner});
}

class ProductDetailError extends ProductDetailState {
  final String message;
  ProductDetailError(this.message);
}

// BLOC
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetOwnerInfoUseCase getOwnerInfoUseCase = GetOwnerInfoUseCase();

  ProductDetailBloc() : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      final owner = await getOwnerInfoUseCase.execute(event.product.ownerId);

      emit(ProductDetailLoaded(product: event.product, owner: owner));
    } catch (e) {
      emit(ProductDetailError('Error al cargar el producto: ${e.toString()}'));
    }
  }
}
