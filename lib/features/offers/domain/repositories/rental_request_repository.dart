import 'package:lendly_app/domain/model/rental_request.dart';

abstract class RentalRequestRepository {
  Future<RentalRequest> createRentalRequest(RentalRequest request);
  Future<List<RentalRequest>> getRentalRequestsByBorrower(String borrowerId);
  Future<List<RentalRequest>> getRentalRequestsByProduct(String productId);
  Future<List<RentalRequest>> getRentalRequestsByOwner(String ownerId);
  Future<RentalRequest?> getRentalRequestById(String requestId);
  Future<RentalRequest> updateRentalRequestStatus(
    String requestId,
    RentalRequestStatus status,
  );
}

