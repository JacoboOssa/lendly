import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/home/domain/usecases/get_available_products_usecase.dart';
import 'package:lendly_app/features/home/data/repositories/home_repository_impl.dart';

// Events
abstract class AvailableProductsEvent {}

class LoadAvailableProducts extends AvailableProductsEvent {
  final bool isInitialLoad;

  LoadAvailableProducts({this.isInitialLoad = false});
}

class SubscribeToProductChanges extends AvailableProductsEvent {}

class UpdateProductsFromStream extends AvailableProductsEvent {
  final String eventType; // "INSERT", "UPDATE", "DELETE"

  UpdateProductsFromStream(this.eventType);
}

class UnsubscribeFromProductChanges extends AvailableProductsEvent {}

// States
abstract class AvailableProductsState {}

class AvailableProductsIdle extends AvailableProductsState {}

class AvailableProductsInitialLoading extends AvailableProductsState {}

class AvailableProductsLoaded extends AvailableProductsState {
  final List<Product> products;
  final bool isRefreshing;

  AvailableProductsLoaded(this.products, {this.isRefreshing = false});
}

class AvailableProductsError extends AvailableProductsState {
  final String message;

  AvailableProductsError(this.message);
}

// BLoC
class AvailableProductsBloc
    extends Bloc<AvailableProductsEvent, AvailableProductsState> {
  final GetAvailableProductsUseCase getAvailableProductsUseCase;
  final HomeRepositoryImpl _repository = HomeRepositoryImpl();
  StreamSubscription<String>? _streamSubscription;

  AvailableProductsBloc({
    GetAvailableProductsUseCase? getAvailableProductsUseCase,
  }) : getAvailableProductsUseCase =
           getAvailableProductsUseCase ?? GetAvailableProductsUseCase(),
       super(AvailableProductsIdle()) {
    on<LoadAvailableProducts>(_onLoadAvailableProducts);
    on<SubscribeToProductChanges>(_onSubscribeToProductChanges);
    on<UpdateProductsFromStream>(_onUpdateProductsFromStream);
    on<UnsubscribeFromProductChanges>(_onUnsubscribeFromProductChanges);
  }

  Future<void> _onLoadAvailableProducts(
    LoadAvailableProducts event,
    Emitter<AvailableProductsState> emit,
  ) async {
    // Skeleton solo en carga inicial
    if (event.isInitialLoad) {
      emit(AvailableProductsInitialLoading());
    } else if (state is AvailableProductsLoaded) {
      // Mantener los productos actuales pero con flag de refreshing
      final currentState = state as AvailableProductsLoaded;
      emit(AvailableProductsLoaded(currentState.products, isRefreshing: true));
    }

    try {
      final products = await getAvailableProductsUseCase.call();
      emit(AvailableProductsLoaded(products));
    } catch (e) {
      emit(AvailableProductsError('Error al cargar productos: $e'));
    }
  }

  Future<void> _onSubscribeToProductChanges(
    SubscribeToProductChanges event,
    Emitter<AvailableProductsState> emit,
  ) async {
    // Cancelar suscripción anterior si existe
    await _streamSubscription?.cancel();

    // Escuchar los cambios desde el repositorio
    _streamSubscription = _repository.listenItemsUpdates().listen(
      (eventType) {
        // Cuando hay un cambio, agregar evento para actualizar productos
        print('🔔 Cambio detectado en items: $eventType');
        add(UpdateProductsFromStream(eventType));
      },
      onError: (error) {
        print('❌ Error en stream de items: $error');
      },
    );
  }

  Future<void> _onUpdateProductsFromStream(
    UpdateProductsFromStream event,
    Emitter<AvailableProductsState> emit,
  ) async {
    // Recargar productos cuando hay un cambio en la base de datos
    try {
      final products = await getAvailableProductsUseCase.call();
      emit(AvailableProductsLoaded(products));
    } catch (e) {
      print('Error al actualizar productos desde stream: $e');
    }
  }

  Future<void> _onUnsubscribeFromProductChanges(
    UnsubscribeFromProductChanges event,
    Emitter<AvailableProductsState> emit,
  ) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
