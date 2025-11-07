import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/publish/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/publish/domain/repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<Product> execute(Product product) async {
    // Validaciones
    if (product.id == null || product.id!.isEmpty) {
      throw Exception('El ID del producto es requerido');
    }

    if (product.title.isEmpty) {
      throw Exception('El título es requerido');
    }

    if (product.pricePerDayCents <= 0) {
      throw Exception('El precio debe ser mayor a 0');
    }

    return await repository.updateProduct(product);
  }
}
