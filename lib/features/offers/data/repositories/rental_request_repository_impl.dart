import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class RentalRequestRepositoryImpl implements RentalRequestRepository {
  final RentalRequestDataSource dataSource;
  final RentalRepository rentalRepository;
  final PaymentRepository paymentRepository;
  final ProductRepository productRepository;

  RentalRequestRepositoryImpl(
    this.dataSource, {
    required this.rentalRepository,
    required this.paymentRepository,
    required this.productRepository,
  });

  @override
  Future<RentalRequest> createRentalRequest(RentalRequest request) {
    return dataSource.createRentalRequest(request);
  }

  @override
  Future<List<RentalRequest>> getRentalRequestsByBorrower(String borrowerId) {
    return dataSource.getRentalRequestsByBorrower(borrowerId);
  }

  @override
  Future<List<RentalRequest>> getRentalRequestsByProduct(String productId) {
    return dataSource.getRentalRequestsByProduct(productId);
  }

  @override
  Future<List<RentalRequest>> getRentalRequestsByOwner(String ownerId) {
    return dataSource.getRentalRequestsByOwner(ownerId);
  }

  @override
  Future<RentalRequest?> getRentalRequestById(String requestId) {
    return dataSource.getRentalRequestById(requestId);
  }

  @override
  Future<RentalRequest> updateRentalRequestStatus(
    String requestId,
    RentalRequestStatus status,
  ) {
    return dataSource.updateRentalRequestStatus(requestId, status);
  }

  @override
  Future<RentalRequest> getRentalRequest(String requestId) async {
    final request = await dataSource.getRentalRequestById(requestId);
    if (request == null) {
      throw Exception('Rental request not found');
    }
    return request;
  }
}

