import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserAccountCreatedDateUseCase {
  final ProfileDetailRepository repository;

  GetUserAccountCreatedDateUseCase() : repository = ProfileDetailRepositoryImpl(ProfileDetailDataSourceImpl());

  Future<DateTime?> execute(String userId) {
    return repository.getUserAccountCreatedDate(userId);
  }
}

