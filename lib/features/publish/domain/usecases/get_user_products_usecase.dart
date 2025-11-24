import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/publish/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/publish/domain/repositories/product_repository.dart';

class GetUserProductsUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<List<Product>> execute(String userId) async {
    if (userId.isEmpty) {
      throw Exception('El ID de usuario es requerido');
    }

    return await repository.getUserProducts(userId);
  }
}
