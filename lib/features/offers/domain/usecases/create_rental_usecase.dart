import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';

class CreateRentalUseCase {
  final RentalRepository repository;

  CreateRentalUseCase({
    required this.repository,
  });

  Future<Rental> execute(Rental rental) {
    return repository.createRental(rental);
  }
}

