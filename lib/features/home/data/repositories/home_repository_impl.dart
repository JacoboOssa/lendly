import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/home/data/source/home_data_source.dart';
import 'package:lendly_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl extends HomeRepository {
  HomeDataSource homeDataSource = HomeDataSourceImpl();

  @override
  Future<String?> getUserRole() {
    return homeDataSource.getUserRole();
  }

  @override
  Future<List<Product>> getAvailableProducts() async {
    try {
      return await homeDataSource.getAvailableProducts();
    } catch (e) {
      throw Exception('Error al obtener productos disponibles: $e');
    }
  }
}
