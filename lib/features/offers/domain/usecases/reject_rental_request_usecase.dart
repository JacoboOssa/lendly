import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';

class RejectRentalRequestUseCase {
  final RentalRequestRepository repository;

  RejectRentalRequestUseCase({
    required this.repository,
  });

  Future<RentalRequest> execute(String requestId) {
    return repository.updateRentalRequestStatus(
      requestId,
      RentalRequestStatus.rejected,
    );
  }
}

