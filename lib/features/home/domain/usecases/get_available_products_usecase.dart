import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:lendly_app/features/home/domain/repositories/home_repository.dart';

class GetAvailableProductsUseCase {
  final HomeRepository repository = HomeRepositoryImpl();

  Future<List<Product>> call() async {
    return await repository.getAvailableProducts();
  }
}
