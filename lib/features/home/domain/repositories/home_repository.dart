import 'package:lendly_app/domain/model/product.dart';

abstract class HomeRepository {
  Future<String?> getUserRole();

  Future<List<Product>> getAvailableProducts();
  Stream<String> listenItemsUpdates();
}
