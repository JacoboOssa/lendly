import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_repository.dart';

class GetCurrentUserUsecase {
  final ProfileRepository repository = ProfileRepositoryImpl();
  Future<AppUser?> execute() {
    return repository.getCurrentUser();
  }
}
