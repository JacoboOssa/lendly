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

class ToggleProductAvailability extends ManageProductsEvent {
  final Product product;

  ToggleProductAvailability(this.product);
}

//ESTADOS
abstract class ManageProductsState {}

class ManageProductsInitial extends ManageProductsState {}

class ManageProductsLoading extends ManageProductsState {
  final bool isInitialLoad;

  ManageProductsLoading({this.isInitialLoad = false});
}

class ManageProductsLoaded extends ManageProductsState {
  final List<Product> products;
  final bool isProcessing; // Para mostrar spinner durante operaciones

  ManageProductsLoaded(this.products, {this.isProcessing = false});
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
    on<ToggleProductAvailability>(_onToggleProductAvailability);
  }

  Future<void> _onLoadUserProducts(
    LoadUserProducts event,
    Emitter<ManageProductsState> emit,
  ) async {
    // Skeleton solo en carga inicial
    emit(ManageProductsLoading(isInitialLoad: true));
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
    // Mantener productos actuales pero con spinner
    if (state is ManageProductsLoaded) {
      final currentState = state as ManageProductsLoaded;
      emit(ManageProductsLoaded(currentState.products, isProcessing: true));
    }

    try {
      // Ejecutar la operación
      await updateProductUseCase.execute(event.product);

      // Recargar todos los productos
      final currentUser = event.product.ownerId;
      final products = await getUserProductsUseCase.execute(currentUser);
      emit(ManageProductsLoaded(products));
    } catch (e) {
      emit(ManageProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ManageProductsState> emit,
  ) async {
    // Mantener productos actuales pero con spinner
    if (state is ManageProductsLoaded) {
      final currentState = state as ManageProductsLoaded;
      emit(ManageProductsLoaded(currentState.products, isProcessing: true));
    }

    try {
      // Ejecutar la operación
      await deleteProductUseCase.execute(event.productId);

      // Recargar todos los productos desde el state actual para obtener el userId
      if (state is ManageProductsLoaded) {
        final currentState = state as ManageProductsLoaded;
        if (currentState.products.isNotEmpty) {
          final userId = currentState.products.first.ownerId;
          final products = await getUserProductsUseCase.execute(userId);
          emit(ManageProductsLoaded(products));
        } else {
          emit(ManageProductsLoaded([]));
        }
      }
    } catch (e) {
      emit(ManageProductsError(e.toString()));
    }
  }

  Future<void> _onToggleProductAvailability(
    ToggleProductAvailability event,
    Emitter<ManageProductsState> emit,
  ) async {
    // Mantener productos actuales pero con spinner
    if (state is ManageProductsLoaded) {
      final currentState = state as ManageProductsLoaded;
      emit(ManageProductsLoaded(currentState.products, isProcessing: true));
    }

    try {
      // Crear una copia del producto con el nuevo estado de disponibilidad
      final updatedProduct = Product(
        id: event.product.id,
        ownerId: event.product.ownerId,
        title: event.product.title,
        description: event.product.description,
        category: event.product.category,
        pricePerDayCents: event.product.pricePerDayCents,
        condition: event.product.condition,
        country: event.product.country,
        city: event.product.city,
        address: event.product.address,
        pickupNotes: event.product.pickupNotes,
        active: event.product.active,
        isAvailable: !event.product.isAvailable, // Toggle
        photoUrl: event.product.photoUrl,
        ratingAvg: event.product.ratingAvg,
        createdAt: event.product.createdAt,
      );

      // Ejecutar la operación
      await updateProductUseCase.execute(updatedProduct);

      // Recargar todos los productos
      final userId = event.product.ownerId;
      final products = await getUserProductsUseCase.execute(userId);
      emit(ManageProductsLoaded(products));
    } catch (e) {
      emit(ManageProductsError('Error al cambiar disponibilidad: $e'));
    }
  }
}
