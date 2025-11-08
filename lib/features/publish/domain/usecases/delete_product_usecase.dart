import 'package:lendly_app/features/publish/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/publish/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<void> execute(String productId) async {
    if (productId.isEmpty) {
      throw Exception('El ID del producto es requerido');
    }

    await repository.deleteProduct(productId);
  }
}
