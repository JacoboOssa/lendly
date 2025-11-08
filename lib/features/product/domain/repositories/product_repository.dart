import 'package:lendly_app/domain/model/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getPaginatedProducts({
    required int page,
    required int pageSize,
  });
}
