import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RentalRequestDataSource {
  Future<RentalRequest> createRentalRequest(RentalRequest request);
  Future<List<RentalRequest>> getRentalRequestsByBorrower(String borrowerId);
  Future<List<RentalRequest>> getRentalRequestsByProduct(String productId);
  Future<RentalRequest?> getRentalRequestById(String requestId);
  Future<RentalRequest> updateRentalRequestStatus(
    String requestId,
    RentalRequestStatus status,
  );
}

class RentalRequestDataSourceImpl implements RentalRequestDataSource {
  @override
  Future<RentalRequest> createRentalRequest(RentalRequest request) async {
    final response = await Supabase.instance.client
        .from('rental_request')
        .insert(request.toJson())
        .select()
        .single();

    return RentalRequest.fromJson(response);
  }

  @override
  Future<List<RentalRequest>> getRentalRequestsByBorrower(
    String borrowerId,
  ) async {
    final response = await Supabase.instance.client
        .from('rental_request')
        .select()
        .eq('borrower_user_id', borrowerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => RentalRequest.fromJson(data))
        .toList();
  }

  @override
  Future<List<RentalRequest>> getRentalRequestsByProduct(
    String productId,
  ) async {
    final response = await Supabase.instance.client
        .from('rental_request')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => RentalRequest.fromJson(data))
        .toList();
  }

  @override
  Future<RentalRequest?> getRentalRequestById(String requestId) async {
    final response = await Supabase.instance.client
        .from('rental_request')
        .select()
        .eq('id', requestId)
        .maybeSingle();

    if (response == null) return null;
    return RentalRequest.fromJson(response);
  }

  @override
  Future<RentalRequest> updateRentalRequestStatus(
    String requestId,
    RentalRequestStatus status,
  ) async {
    final statusString = RentalRequest.statusToDbString(status);
    final response = await Supabase.instance.client
        .from('rental_request')
        .update({
          'status': statusString,
        })
        .eq('id', requestId)
        .select()
        .single();

    return RentalRequest.fromJson(response);
  }
}

