import 'package:lendly_app/domain/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDataSource {
  Future<void> createUser(AppUser user);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
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

  @override
  Future<AppUser?> getCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return Future.value(null);
    return Supabase.instance.client
        .from("users_app")
        .select()
        .eq("id", user.id)
        .single()
        .then((value) => AppUser.fromJson(value));
  }
}
