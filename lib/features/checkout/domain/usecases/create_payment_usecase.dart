import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase({
    PaymentRepository? repository,
  }) : repository = repository ?? PaymentRepositoryImpl(PaymentDataSourceImpl());

  Future<Payment> execute({
    required String rentalId,
    required String ownerUserId,
    required String borrowerUserId,
    required RentalRequest rentalRequest,
    required Product product,
  }) async {
    final numberOfDays = rentalRequest.endDate.difference(rentalRequest.startDate).inDays + 1;
    
    final dailyPrice = product.pricePerDayCents / 100.0;
    
    final totalAmount = dailyPrice * numberOfDays;

    final payment = Payment(
      rentalId: rentalId,
      ownerUserId: ownerUserId,
      borrowerUserId: borrowerUserId,
      startDate: rentalRequest.startDate,
      endDate: rentalRequest.endDate,
      dailyPrice: dailyPrice,
      totalAmount: totalAmount,
      paid: false,
      numberOfDays: numberOfDays,
      createdAt: DateTime.now(),
    );

    return await repository.createPayment(payment);
  }
}

