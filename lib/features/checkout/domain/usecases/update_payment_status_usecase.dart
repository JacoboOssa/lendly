import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';

class UpdatePaymentStatusUseCase {
  final PaymentRepository repository;

  UpdatePaymentStatusUseCase({
    PaymentRepository? repository,
  }) : repository = repository ?? PaymentRepositoryImpl(PaymentDataSourceImpl());

  Future<Payment> execute(String paymentId, bool paid) async {
    return await repository.updatePaymentStatus(paymentId, paid);
  }
}

