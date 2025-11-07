import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';
import 'package:lendly_app/features/publish/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/publish/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<Product> execute({
    required Product product,
    required List<Availability> availabilities,
    Object? photoBytes,
  }) async {
    if (product.title.trim().isEmpty) {
      throw Exception('El título es requerido');
    }

    if (product.pricePerDayCents <= 0) {
      throw Exception('El precio debe ser mayor a 0');
    }

    if (availabilities.isEmpty) {
      throw Exception('Debe especificar al menos una fecha de disponibilidad');
    }

    for (final availability in availabilities) {
      if (availability.endDate.isBefore(availability.startDate)) {
        throw Exception(
          'La fecha de fin debe ser posterior a la fecha de inicio',
        );
      }
    }

    return await repository.createProduct(
      product: product,
      availabilities: availabilities,
      photoBytes: photoBytes,
    );
  }
}
