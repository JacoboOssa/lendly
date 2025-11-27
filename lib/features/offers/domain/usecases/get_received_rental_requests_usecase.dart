import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';

class GetReceivedRentalRequestsUseCase {
  final RentalRequestRepository repository;

  GetReceivedRentalRequestsUseCase({
    required this.repository,
  });

  Future<List<RentalRequest>> execute(String ownerId) {
    return repository.getRentalRequestsByOwner(ownerId);
  }
}

