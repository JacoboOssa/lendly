import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/product/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/product/domain/repositories/rental_request_repository.dart';

class RentalRequestRepositoryImpl implements RentalRequestRepository {
  final RentalRequestDataSource dataSource;

  RentalRequestRepositoryImpl(this.dataSource);

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
}

