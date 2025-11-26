import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/auth/data/source/auth_data_source.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';
import 'package:lendly_app/features/profile/data/source/profile_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  AuthDataSource authDataSource = AuthDataSourceImpl();
  ProfileDataSource profileDataSource = ProfileDataSourceImpl();

  @override
  Future<void> registerUser(String email, String password, AppUser user) async {
    String? userId = await authDataSource.signUp(email, password);

    if (userId != null) {
      user.id = userId;
      await profileDataSource.createUser(user);
    }
  }

  @override
  Future<void> signIn(String email, String password) {
    return authDataSource.signIn(email, password);
  }

  @override
  Future<String?> getCurrentUserId() {
    return authDataSource.getCurrentUserId();
  }
}
