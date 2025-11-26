import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';

class CreateRentalRequestUseCase {
  final RentalRequestRepository repository = RentalRequestRepositoryImpl(
    RentalRequestDataSourceImpl(),
  );

  Future<RentalRequest> execute(RentalRequest request) {
    return repository.createRentalRequest(request);
  }
}

