import 'package:lendly_app/domain/model/payment.dart';

abstract class PaymentRepository {
  Future<Payment> createPayment(Payment payment);
  Future<Payment?> getPaymentByRentalId(String rentalId);
  Future<Payment> updatePaymentStatus(String paymentId, bool paid);
}

