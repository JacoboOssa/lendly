import 'package:lendly_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';

class GetCurrentUserIdUseCase {
  final UserRepository repository = UserRepositoryImpl();

  Future<String?> execute() async {
    return repository.getCurrentUserId();
  }
}

