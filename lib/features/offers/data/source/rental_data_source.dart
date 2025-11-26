import 'package:lendly_app/domain/model/rental.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RentalDataSource {
  Future<Rental> createRental(Rental rental);
  Future<Rental?> getRentalByRequestId(String rentalRequestId);
  Future<List<Rental>> getRentalsByBorrower(String borrowerId, {String? status});
  Future<List<Rental>> getRentalsByProduct(String productId);
  Future<List<Rental>> getRentalsByLender(String lenderId, {String? status});
}

class RentalDataSourceImpl implements RentalDataSource {
  @override
  Future<Rental> createRental(Rental rental) async {
    final response = await Supabase.instance.client
        .from('rental')
        .insert(rental.toJson())
        .select()
        .single();

    return Rental.fromJson(response);
  }

  @override
  Future<Rental?> getRentalByRequestId(String rentalRequestId) async {
    final response = await Supabase.instance.client
        .from('rental')
        .select()
        .eq('rental_request_id', rentalRequestId)
        .maybeSingle();

    if (response == null) return null;
    return Rental.fromJson(response);
  }

  @override
  Future<List<Rental>> getRentalsByBorrower(String borrowerId, {String? status}) async {
    var query = Supabase.instance.client
        .from('rental')
        .select()
        .eq('borrower_user_id', borrowerId);
    
    if (status != null) {
      query = query.eq('status', status);
    }
    
    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((data) => Rental.fromJson(data))
        .toList();
  }

  @override
  Future<List<Rental>> getRentalsByLender(String lenderId, {String? status}) async {
    // Primero obtener los productos del lender
    final productsResponse = await Supabase.instance.client
        .from('items')
        .select('id')
        .eq('owner_id', lenderId);

    if (productsResponse.isEmpty) {
      return [];
    }

    final productIds = (productsResponse as List)
        .map((p) => p['id'] as String)
        .toList();

    if (productIds.isEmpty) {
      return [];
    }

    // Obtener rentals de esos productos
    var query = Supabase.instance.client
        .from('rental')
        .select();

    if (status != null) {
      query = query.eq('status', status);
    }

    if (productIds.length == 1) {
      query = query.eq('product_id', productIds[0]);
    } else {
      final orConditions = productIds
          .map((id) => 'product_id.eq.$id')
          .join(',');
      query = query.or(orConditions);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((data) => Rental.fromJson(data))
        .toList();
  }

  @override
  Future<List<Rental>> getRentalsByProduct(String productId) async {
    final response = await Supabase.instance.client
        .from('rental')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => Rental.fromJson(data))
        .toList();
  }
}

