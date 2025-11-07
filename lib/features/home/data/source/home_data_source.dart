import 'package:lendly_app/domain/model/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeDataSource {
  Future<String?> getUserRole();
  Future<List<Product>> getAvailableProducts();
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

  @override
  Future<List<Product>> getAvailableProducts() async {
    final response = await Supabase.instance.client
        .from('items')
        .select()
        .eq('is_available', true)
        .eq('active', true)
        .order('created_at', ascending: false);

    return (response as List).map((data) => Product.fromJson(data)).toList();
  }
}
