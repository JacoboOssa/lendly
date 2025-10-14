import 'package:lendly_app/features/profile/data/source/profile_data_source.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  ProfileDataSource profileDataSource = ProfileDataSourceImpl();

  @override
  Future<void> logout() {
    return profileDataSource.logout();
  }
}
