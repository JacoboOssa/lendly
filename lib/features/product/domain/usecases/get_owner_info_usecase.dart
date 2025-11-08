import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class GetOwnerInfoUseCase {
  final ProductRepository repository = ProductRepositoryImpl();

  Future<AppUser?> execute(String ownerId) {
    return repository.getOwnerInfo(ownerId);
  }
}
