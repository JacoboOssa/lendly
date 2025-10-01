// domain/usecases/register_user_usecase.dart
import 'package:lendly_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository = UserRepositoryImpl();

  Future<void> execute(String email, String password, String name) {
    return repository.registerUser(email, password, name);
  }
}
