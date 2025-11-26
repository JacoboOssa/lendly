import 'package:lendly_app/domain/model/rental.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RentalDataSource {
  Future<Rental> createRental(Rental rental);
  Future<Rental?> getRentalByRequestId(String rentalRequestId);
  Future<List<Rental>> getRentalsByBorrower(String borrowerId);
  Future<List<Rental>> getRentalsByProduct(String productId);
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
  Future<List<Rental>> getRentalsByBorrower(String borrowerId) async {
    final response = await Supabase.instance.client
        .from('rental')
        .select()
        .eq('borrower_user_id', borrowerId)
        .order('created_at', ascending: false);

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

