//EVENTOS
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';
import 'package:lendly_app/features/publish/domain/usecases/create_product_usecase.dart';

abstract class CreateProductEvent {}

class CreateProductSubmitted extends CreateProductEvent {
  final Product product;
  final List<Availability> availabilities;
  final Uint8List? photoBytes;

  CreateProductSubmitted({
    required this.product,
    required this.availabilities,
    this.photoBytes,
  });
}

//ESTADOS
abstract class CreateProductState {}

class CreateProductIdle extends CreateProductState {}

class CreateProductLoading extends CreateProductState {}

class CreateProductSuccess extends CreateProductState {
  final Product product;

  CreateProductSuccess(this.product);
}

class CreateProductError extends CreateProductState {
  final String message;

  CreateProductError(this.message);
}

//BLOC
class CreateProductBloc extends Bloc<CreateProductEvent, CreateProductState> {
  final CreateProductUseCase createProductUseCase = CreateProductUseCase();

  CreateProductBloc() : super(CreateProductIdle()) {
    on<CreateProductSubmitted>(_onCreateProductSubmitted);
  }

  Future<void> _onCreateProductSubmitted(
    CreateProductSubmitted event,
    Emitter<CreateProductState> emit,
  ) async {
    emit(CreateProductLoading());

    try {
      final product = await createProductUseCase.execute(
        product: event.product,
        availabilities: event.availabilities,
        photoBytes: event.photoBytes,
      );

      emit(CreateProductSuccess(product));
    } catch (e) {
      emit(CreateProductError(e.toString()));
    }
  }
}
