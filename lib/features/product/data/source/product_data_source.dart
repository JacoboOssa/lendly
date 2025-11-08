import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductDataSource {
  Future<List<Product>> getPaginatedProducts({
    required int page,
    required int pageSize,
  });
  Future<AppUser?> getOwnerInfo(String ownerId);
}

class ProductDataSourceImpl extends ProductDataSource {
  @override
  Future<List<Product>> getPaginatedProducts({
    required int page,
    required int pageSize,
  }) async {
    // page viene como 0, 1, 2, etc. desde el BLoC
    final int start = page * pageSize;
    final int end = start + pageSize - 1;

    final response = await Supabase.instance.client
        .from('items')
        .select()
        .eq('is_available', true)
        .eq('active', true)
        .order('created_at', ascending: false)
        .range(start, end);

    return (response as List).map((data) => Product.fromJson(data)).toList();
  }

  @override
  Future<AppUser?> getOwnerInfo(String ownerId) async {
    final response = await Supabase.instance.client
        .from('users_app')
        .select()
        .eq('id', ownerId)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }
}
