import 'package:lendly_app/domain/model/return.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReturnDataSource {
  Future<Return> createReturn(Return returnData);
  Future<Return?> getReturnByRentalId(String rentalId);
  Future<Return> updateReturnStatus(String returnId, ReturnStatus status);
}

class ReturnDataSourceImpl implements ReturnDataSource {
  @override
  Future<Return> createReturn(Return returnData) async {
    final response = await Supabase.instance.client
        .from('returns')
        .insert(returnData.toJson())
        .select()
        .single();

    return Return.fromJson(response);
  }

  @override
  Future<Return?> getReturnByRentalId(String rentalId) async {
    final response = await Supabase.instance.client
        .from('returns')
        .select()
        .eq('rental_id', rentalId)
        .maybeSingle();

    if (response == null) return null;
    return Return.fromJson(response);
  }

  @override
  Future<Return> updateReturnStatus(String returnId, ReturnStatus status) async {
    final response = await Supabase.instance.client
        .from('returns')
        .update({'status': Return.statusToDbString(status)})
        .eq('id', returnId)
        .select()
        .single();

    return Return.fromJson(response);
  }
}

