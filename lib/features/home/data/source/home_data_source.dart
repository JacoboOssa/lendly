import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeDataSource {
  Future<String?> getUserRole();
}

class HomeDataSourceImpl extends HomeDataSource {
  @override
  Future<String?> getUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await Supabase.instance.client
          .from('users_app')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] as String?;
    } catch (e) {
      return null;
    }
  }
}
