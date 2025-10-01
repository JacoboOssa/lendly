// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<void> registerUser(String email, String password, String name);
}
