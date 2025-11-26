import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDataSource dataSource;

  PaymentRepositoryImpl(this.dataSource);

  @override
  Future<Payment> createPayment(Payment payment) {
    return dataSource.createPayment(payment);
  }

  @override
  Future<Payment?> getPaymentByRentalId(String rentalId) {
    return dataSource.getPaymentByRentalId(rentalId);
  }

  @override
  Future<Payment> updatePaymentStatus(String paymentId, bool paid) {
    return dataSource.updatePaymentStatus(paymentId, paid);
  }
}

