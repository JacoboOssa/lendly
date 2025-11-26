import 'package:lendly_app/domain/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDetailDataSource {
  Future<AppUser?> getUserById(String userId);
  Future<DateTime?> getUserAccountCreatedDate(String userId);
  Future<int> getCompletedRentalsCountForLender(String userId);
  Future<int> getCompletedRentalsCountForBorrower(String userId);
}

class ProfileDetailDataSourceImpl implements ProfileDetailDataSource {
  @override
  Future<AppUser?> getUserById(String userId) async {
    final response = await Supabase.instance.client
        .from('users_app')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }

  @override
  Future<DateTime?> getUserAccountCreatedDate(String userId) async {
    // Intentar obtener desde users_app si tiene created_at
    // Si no existe, podemos usar una fecha por defecto o null
    try {
      final response = await Supabase.instance.client
          .from('users_app')
          .select('created_at')
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null && response['created_at'] != null) {
        return DateTime.parse(response['created_at']);
      }
      
      // Si no hay created_at en users_app, retornar null
      // En producción, esto debería estar disponible
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getCompletedRentalsCountForLender(String userId) async {
    // Para lender: contar rentals completados donde el producto pertenece al usuario
    // Primero obtener los IDs de productos del owner
    final productsResponse = await Supabase.instance.client
        .from('items')
        .select('id')
        .eq('owner_id', userId);

    if (productsResponse.isEmpty) {
      return 0;
    }

    final productIds = (productsResponse as List)
        .map((p) => p['id'] as String)
        .toList();

    if (productIds.isEmpty) {
      return 0;
    }

    // Contar rentals completados para estos productos
    var query = Supabase.instance.client
        .from('rental')
        .select('id')
        .eq('status', 'COMPLETED');

    // Construir la condición OR para múltiples product_ids
    if (productIds.length == 1) {
      query = query.eq('product_id', productIds[0]);
    } else {
      final orConditions = productIds
          .map((id) => 'product_id.eq.$id')
          .join(',');
      query = query.or(orConditions);
    }

    final response = await query;
    return (response as List).length;
  }

  @override
  Future<int> getCompletedRentalsCountForBorrower(String userId) async {
    // Para borrower: contar rentals completados donde borrower_user_id es el usuario
    final response = await Supabase.instance.client
        .from('rental')
        .select('id')
        .eq('borrower_user_id', userId)
        .eq('status', 'COMPLETED');

    return (response as List).length;
  }
}

