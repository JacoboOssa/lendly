import 'package:lendly_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_repository.dart';

class LogoutUsecase {
  final ProfileRepository repository = ProfileRepositoryImpl();
  Future<void> execute() {
    return repository.logout();
  }
}
