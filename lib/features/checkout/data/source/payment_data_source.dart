import 'package:lendly_app/domain/model/payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PaymentDataSource {
  Future<Payment> createPayment(Payment payment);
  Future<Payment?> getPaymentByRentalId(String rentalId);
  Future<Payment> updatePaymentStatus(String paymentId, bool paid);
}

class PaymentDataSourceImpl implements PaymentDataSource {
  @override
  Future<Payment> createPayment(Payment payment) async {
    final response = await Supabase.instance.client
        .from('payment')
        .insert(payment.toJson())
        .select()
        .single();

    return Payment.fromJson(response);
  }

  @override
  Future<Payment?> getPaymentByRentalId(String rentalId) async {
    final response = await Supabase.instance.client
        .from('payment')
        .select()
        .eq('rental_id', rentalId)
        .maybeSingle();

    if (response == null) return null;
    return Payment.fromJson(response);
  }

  @override
  Future<Payment> updatePaymentStatus(String paymentId, bool paid) async {
    final response = await Supabase.instance.client
        .from('payment')
        .update({'paid': paid})
        .eq('id', paymentId)
        .select()
        .single();

    return Payment.fromJson(response);
  }
}

