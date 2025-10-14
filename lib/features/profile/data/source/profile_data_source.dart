import 'package:lendly_app/domain/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDataSource {
  Future<void> createUser(AppUser user);
  Future<void> logout();
}

class ProfileDataSourceImpl extends ProfileDataSource {
  @override
  Future<void> createUser(AppUser user) async {
    await Supabase.instance.client.from("users_app").insert(user.toJson());
  }

  @override
  Future<void> logout() {
    return Supabase.instance.client.auth.signOut();
  }
}
