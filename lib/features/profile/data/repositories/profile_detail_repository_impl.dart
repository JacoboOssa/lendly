import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class ProfileDetailRepositoryImpl implements ProfileDetailRepository {
  final ProfileDetailDataSource dataSource;

  ProfileDetailRepositoryImpl(this.dataSource);

  @override
  Future<AppUser?> getUserById(String userId) {
    return dataSource.getUserById(userId);
  }

  @override
  Future<DateTime?> getUserAccountCreatedDate(String userId) {
    return dataSource.getUserAccountCreatedDate(userId);
  }

  @override
  Future<int> getCompletedRentalsCountForLender(String userId) {
    return dataSource.getCompletedRentalsCountForLender(userId);
  }

  @override
  Future<int> getCompletedRentalsCountForBorrower(String userId) {
    return dataSource.getCompletedRentalsCountForBorrower(userId);
  }
}

