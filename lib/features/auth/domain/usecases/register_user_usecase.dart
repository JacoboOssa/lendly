// domain/usecases/register_user_usecase.dart
import 'package:lendly_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';
import 'package:lendly_app/domain/model/app_user.dart';

class RegisterUserUseCase {
  final UserRepository repository = UserRepositoryImpl();

  Future<void> execute(String email, String password, AppUser user) {
    return repository.registerUser(email, password, user);
  }
}
