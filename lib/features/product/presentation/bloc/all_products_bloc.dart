import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/product/domain/usecases/get_paginated_products_usecase.dart';

// Events
abstract class AllProductsEvent {}

class LoadAllProducts extends AllProductsEvent {
  final bool isInitialLoad;

  LoadAllProducts({this.isInitialLoad = false});
}

class GoToPage extends AllProductsEvent {
  final int page;

  GoToPage(this.page);
}

class NextPage extends AllProductsEvent {}

class PreviousPage extends AllProductsEvent {}

// States
abstract class AllProductsState {}

class AllProductsIdle extends AllProductsState {}

class AllProductsLoading extends AllProductsState {}

class AllProductsLoaded extends AllProductsState {
  final List<Product> products;
  final int currentPage;
  final int totalPages;
  final bool isLoading;

  AllProductsLoaded({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    this.isLoading = false,
  });
}

class AllProductsError extends AllProductsState {
  final String message;

  AllProductsError(this.message);
}

// BLoC
class AllProductsBloc extends Bloc<AllProductsEvent, AllProductsState> {
  final GetPaginatedProductsUseCase getPaginatedProductsUseCase =
      GetPaginatedProductsUseCase();
  static const int pageSize = 10;
  int currentPage = 0;
  int totalPages = 1;

  AllProductsBloc() : super(AllProductsIdle()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<GoToPage>(_onGoToPage);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<AllProductsState> emit,
  ) async {
    if (event.isInitialLoad) {
      emit(AllProductsLoading());
      currentPage = 0;
    }

    try {
      final products = await getPaginatedProductsUseCase.execute(
        page: currentPage,
        pageSize: pageSize,
      );

      if (products.length < pageSize) {
        totalPages = currentPage + 1;
      } else {
        totalPages = currentPage + 2;
      }

      emit(
        AllProductsLoaded(
          products: products,
          currentPage: currentPage,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      emit(AllProductsError('Error al cargar productos: $e'));
    }
  }

  Future<void> _onGoToPage(
    GoToPage event,
    Emitter<AllProductsState> emit,
  ) async {
    if (state is! AllProductsLoaded) return;

    final currentState = state as AllProductsLoaded;
    if (event.page < 0 || event.page >= currentState.totalPages) return;

    emit(
      AllProductsLoaded(
        products: currentState.products,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        isLoading: true,
      ),
    );

    try {
      currentPage = event.page;
      final products = await getPaginatedProductsUseCase.execute(
        page: currentPage,
        pageSize: pageSize,
      );

      if (products.length < pageSize) {
        totalPages = currentPage + 1;
      } else if (currentPage + 1 >= totalPages) {
        totalPages = currentPage + 2;
      }

      emit(
        AllProductsLoaded(
          products: products,
          currentPage: currentPage,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      emit(
        AllProductsLoaded(
          products: currentState.products,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          isLoading: false,
        ),
      );
      print('Error al cargar página: $e');
    }
  }

  Future<void> _onNextPage(
    NextPage event,
    Emitter<AllProductsState> emit,
  ) async {
    if (state is! AllProductsLoaded) return;

    final currentState = state as AllProductsLoaded;
    if (currentState.currentPage >= currentState.totalPages - 1) return;

    add(GoToPage(currentState.currentPage + 1));
  }

  Future<void> _onPreviousPage(
    PreviousPage event,
    Emitter<AllProductsState> emit,
  ) async {
    if (state is! AllProductsLoaded) return;

    final currentState = state as AllProductsLoaded;
    if (currentState.currentPage <= 0) return;

    add(GoToPage(currentState.currentPage - 1));
  }
}
