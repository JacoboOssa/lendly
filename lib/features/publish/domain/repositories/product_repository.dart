import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';

abstract class ProductRepository {
  Future<Product> createProduct({
    required Product product,
    required List<Availability> availabilities,
    Object? photoBytes,
  });

  Future<List<Product>> getUserProducts(String userId);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String productId);
}
