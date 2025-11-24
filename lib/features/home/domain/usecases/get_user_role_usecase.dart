import 'package:lendly_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:lendly_app/features/home/domain/repositories/home_repository.dart';

class GetUserRoleUseCase {
  final HomeRepository repository = HomeRepositoryImpl();

  Future<String?> execute() {
    return repository.getUserRole();
  }
}
