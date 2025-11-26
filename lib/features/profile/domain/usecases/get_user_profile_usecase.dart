import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserProfileUseCase {
  final ProfileDetailRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<AppUser?> execute(String userId) {
    return repository.getUserById(userId);
  }
}

