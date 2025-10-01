// data/repositories/user_repository_impl.dart
import 'package:lendly_app/features/auth/data/source/auth_data_source.dart';
import 'package:lendly_app/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthDataSource authDataSource = AuthDataSourceImpl();
  // UserRepositoryImpl(this.authDataSource);

  @override
  Future<void> registerUser(String email, String password, String name) async {
    final userId = await authDataSource.signUp(email, password);
  }
}
