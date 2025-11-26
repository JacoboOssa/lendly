import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/rating.dart';
import 'package:lendly_app/features/product/domain/usecases/get_owner_info_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/get_product_average_rating_usecase.dart';
import 'package:lendly_app/features/rating/domain/usecases/get_product_ratings_paginated_usecase.dart';

// EVENTS
abstract class ProductDetailEvent {}

class LoadProductDetail extends ProductDetailEvent {
  final Product product;
  LoadProductDetail(this.product);
}

class LoadMoreProductRatings extends ProductDetailEvent {}

// STATES
abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final Product product;
  final AppUser? owner;
  final double? averageRating;
  final List<Rating> ratings;
  final int currentPage;
  final bool hasMoreRatings;
  final bool isLoadingMoreRatings;

  ProductDetailLoaded({
    required this.product,
    this.owner,
    this.averageRating,
    this.ratings = const [],
    this.currentPage = 0,
    this.hasMoreRatings = true,
    this.isLoadingMoreRatings = false,
  });

  ProductDetailLoaded copyWith({
    Product? product,
    AppUser? owner,
    double? averageRating,
    List<Rating>? ratings,
    int? currentPage,
    bool? hasMoreRatings,
    bool? isLoadingMoreRatings,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      owner: owner ?? this.owner,
      averageRating: averageRating ?? this.averageRating,
      ratings: ratings ?? this.ratings,
      currentPage: currentPage ?? this.currentPage,
      hasMoreRatings: hasMoreRatings ?? this.hasMoreRatings,
      isLoadingMoreRatings: isLoadingMoreRatings ?? this.isLoadingMoreRatings,
    );
  }
}

class ProductDetailError extends ProductDetailState {
  final String message;
  ProductDetailError(this.message);
}

// BLOC
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetOwnerInfoUseCase getOwnerInfoUseCase = GetOwnerInfoUseCase();
  final GetProductAverageRatingUseCase getProductAverageRatingUseCase = GetProductAverageRatingUseCase();
  final GetProductRatingsPaginatedUseCase getProductRatingsPaginatedUseCase = GetProductRatingsPaginatedUseCase();

  static const int pageSize = 10;

  ProductDetailBloc() : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
    on<LoadMoreProductRatings>(_onLoadMoreProductRatings);
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      final owner = await getOwnerInfoUseCase.execute(event.product.ownerId);

      // Obtener promedio de calificaciones del producto
      final averageRating = event.product.id != null
          ? await getProductAverageRatingUseCase.execute(event.product.id!)
          : null;

      // Cargar primera página de ratings
      final ratings = event.product.id != null
          ? await getProductRatingsPaginatedUseCase.execute(
              productId: event.product.id!,
              page: 0,
              pageSize: pageSize,
            )
          : <Rating>[];

      emit(ProductDetailLoaded(
        product: event.product,
        owner: owner,
        averageRating: averageRating,
        ratings: ratings,
        currentPage: 0,
        hasMoreRatings: ratings.length >= pageSize,
      ));
    } catch (e) {
      emit(ProductDetailError('Error al cargar el producto: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreProductRatings(
    LoadMoreProductRatings event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (state is! ProductDetailLoaded) return;
    final currentState = state as ProductDetailLoaded;

    if (currentState.product.id == null ||
        !currentState.hasMoreRatings ||
        currentState.isLoadingMoreRatings) return;

    emit(currentState.copyWith(isLoadingMoreRatings: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newRatings = await getProductRatingsPaginatedUseCase.execute(
        productId: currentState.product.id!,
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
