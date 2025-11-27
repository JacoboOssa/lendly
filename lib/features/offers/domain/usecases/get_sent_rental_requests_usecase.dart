import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';

class GetSentRentalRequestsUseCase {
  final RentalRequestRepository repository;

  GetSentRentalRequestsUseCase({
    required this.repository,
  });

  Future<List<RentalRequest>> execute(String borrowerId) {
    return repository.getRentalRequestsByBorrower(borrowerId);
  }
}

