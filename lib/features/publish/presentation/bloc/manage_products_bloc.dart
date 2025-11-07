//EVENTOS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/publish/domain/usecases/get_user_products_usecase.dart';
import 'package:lendly_app/features/publish/domain/usecases/update_product_usecase.dart';
import 'package:lendly_app/features/publish/domain/usecases/delete_product_usecase.dart';

abstract class ManageProductsEvent {}

class LoadUserProducts extends ManageProductsEvent {
  final String userId;

  LoadUserProducts(this.userId);
}

class UpdateProduct extends ManageProductsEvent {
  final Product product;

  UpdateProduct(this.product);
}

class DeleteProduct extends ManageProductsEvent {
  final String productId;

  DeleteProduct(this.productId);
}

//ESTADOS
abstract class ManageProductsState {}

class ManageProductsInitial extends ManageProductsState {}

class ManageProductsLoading extends ManageProductsState {}

class ManageProductsLoaded extends ManageProductsState {
  final List<Product> products;

  ManageProductsLoaded(this.products);
}

class ManageProductsError extends ManageProductsState {
  final String message;

  ManageProductsError(this.message);
}

class ProductUpdated extends ManageProductsState {
  final Product product;

  ProductUpdated(this.product);
}

class ProductDeleted extends ManageProductsState {
  final String productId;

  ProductDeleted(this.productId);
}

//BLOC
class ManageProductsBloc
    extends Bloc<ManageProductsEvent, ManageProductsState> {
  final GetUserProductsUseCase getUserProductsUseCase =
      GetUserProductsUseCase();
  final UpdateProductUseCase updateProductUseCase = UpdateProductUseCase();
  final DeleteProductUseCase deleteProductUseCase = DeleteProductUseCase();

  ManageProductsBloc() : super(ManageProductsInitial()) {
    on<LoadUserProducts>(_onLoadUserProducts);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadUserProducts(
    LoadUserProducts event,
    Emitter<ManageProductsState> emit,
  ) async {
    emit(ManageProductsLoading());
    try {
      final products = await getUserProductsUseCase.execute(event.userId);
      emit(ManageProductsLoaded(products));
    } catch (e) {
      emit(ManageProductsError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ManageProductsState> emit,
  ) async {
    emit(ManageProductsLoading());
    try {
      final updatedProduct = await updateProductUseCase.execute(event.product);
      emit(ProductUpdated(updatedProduct));
    } catch (e) {
      emit(ManageProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ManageProductsState> emit,
  ) async {
    emit(ManageProductsLoading());
    try {
      await deleteProductUseCase.execute(event.productId);
      emit(ProductDeleted(event.productId));
    } catch (e) {
      emit(ManageProductsError(e.toString()));
    }
  }
}
