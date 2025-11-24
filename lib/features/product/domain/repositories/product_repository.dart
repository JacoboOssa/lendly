import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';

abstract class ProductRepository {
  Future<List<Product>> getPaginatedProducts({
    required int page,
    required int pageSize,
  });
  Future<AppUser?> getOwnerInfo(String ownerId);
}
