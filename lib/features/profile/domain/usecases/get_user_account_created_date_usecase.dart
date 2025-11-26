import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserAccountCreatedDateUseCase {
  final ProfileDetailRepository repository;

  GetUserAccountCreatedDateUseCase(this.repository);

  Future<DateTime?> execute(String userId) {
    return repository.getUserAccountCreatedDate(userId);
  }
}

