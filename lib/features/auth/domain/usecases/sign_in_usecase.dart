import 'package:lendly_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';

class SignInUsecase {
  final UserRepository repository = UserRepositoryImpl();

  Future<void> execute(String email, String password) {
    return repository.signIn(email, password);
  }
}
