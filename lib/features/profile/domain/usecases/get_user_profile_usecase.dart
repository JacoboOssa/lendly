import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserProfileUseCase {
  final ProfileDetailRepository repository;

  GetUserProfileUseCase() : repository = ProfileDetailRepositoryImpl(ProfileDetailDataSourceImpl());

  Future<AppUser?> execute(String userId) {
    return repository.getUserById(userId);
  }
}

