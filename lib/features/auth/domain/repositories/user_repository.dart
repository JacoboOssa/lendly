// domain/repositories/user_repository.dart

import 'package:lendly_app/domain/model/app_user.dart';

abstract class UserRepository {
  Future<void> registerUser(String email, String password, AppUser user);
}
