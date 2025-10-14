import 'package:lendly_app/domain/model/app_user.dart';

abstract class ProfileRepository {
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
