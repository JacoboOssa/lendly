import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/home/domain/usecases/get_available_products_usecase.dart';
import 'package:lendly_app/features/home/domain/usecases/listen_items_updates_usecase.dart';

// Events
abstract class AvailableProductsEvent {}

class LoadAvailableProducts extends AvailableProductsEvent {
  final bool isInitialLoad;

  LoadAvailableProducts({this.isInitialLoad = false});
}

class UpdateProductsFromStream extends AvailableProductsEvent {
  final String eventType;

  UpdateProductsFromStream(this.eventType);
}

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
  final GetAvailableProductsUseCase getAvailableProductsUseCase =
      GetAvailableProductsUseCase();
  final ListenItemsUpdatesUsecase listenItemsUpdatesUsecase =
      ListenItemsUpdatesUsecase();

  AvailableProductsBloc() : super(AvailableProductsIdle()) {
    on<LoadAvailableProducts>(_onLoadAvailableProducts);
    on<UpdateProductsFromStream>(_onUpdateProductsFromStream);
  }
  Future<void> _onLoadAvailableProducts(
    LoadAvailableProducts event,
    Emitter<AvailableProductsState> emit,
  ) async {
    if (event.isInitialLoad) {
      emit(AvailableProductsInitialLoading());

      // Suscribirse al stream de cambios en items
      Stream<String> stream = listenItemsUpdatesUsecase.execute();
      stream.listen((eventType) {
        add(UpdateProductsFromStream(eventType));
      });
    } else if (state is AvailableProductsLoaded) {
      final currentState = state as AvailableProductsLoaded;
      emit(AvailableProductsLoaded(currentState.products, isRefreshing: true));
    }

    try {
      final products = await getAvailableProductsUseCase.execute();
      emit(AvailableProductsLoaded(products));
    } catch (e) {
      emit(AvailableProductsError('Error al cargar productos: $e'));
    }
  }

  Future<void> _onUpdateProductsFromStream(
    UpdateProductsFromStream event,
    Emitter<AvailableProductsState> emit,
  ) async {
    try {
      final products = await getAvailableProductsUseCase.execute();
      emit(AvailableProductsLoaded(products));
    } catch (e) {
      print('Error al actualizar productos desde stream: $e');
    }
  }
}
