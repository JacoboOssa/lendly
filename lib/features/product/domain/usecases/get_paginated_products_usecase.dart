import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class GetPaginatedProductsUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<List<Product>> execute({required int page, required int pageSize}) {
    return repository.getPaginatedProducts(page: page, pageSize: pageSize);
  }
}
