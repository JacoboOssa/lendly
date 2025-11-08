import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/product/data/source/product_data_source.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource = ProductDataSourceImpl();

  @override
  Future<List<Product>> getPaginatedProducts({
    required int page,
    required int pageSize,
  }) {
    return dataSource.getPaginatedProducts(page: page, pageSize: pageSize);
  }
}
