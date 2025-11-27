import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/product/data/repositories/product_repository_impl.dart';

class CreateRentalRequestUseCase {
  final RentalRequestRepository repository;

  CreateRentalRequestUseCase() : repository = RentalRequestRepositoryImpl(
    RentalRequestDataSourceImpl(),
    rentalRepository: RentalRepositoryImpl(RentalDataSourceImpl()),
    paymentRepository: PaymentRepositoryImpl(PaymentDataSourceImpl()),
    productRepository: ProductRepositoryImpl(),
  );

  Future<RentalRequest> execute(RentalRequest request) {
    return repository.createRentalRequest(request);
  }
}

