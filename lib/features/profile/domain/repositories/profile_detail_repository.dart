import 'package:lendly_app/domain/model/app_user.dart';

abstract class ProfileDetailRepository {
  Future<AppUser?> getUserById(String userId);
  Future<DateTime?> getUserAccountCreatedDate(String userId);
  Future<int> getCompletedRentalsCountForLender(String userId);
  Future<int> getCompletedRentalsCountForBorrower(String userId);
}

