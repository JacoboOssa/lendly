import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';

class CreateRentalUseCase {
  final RentalRepository repository = RentalRepositoryImpl(
    RentalDataSourceImpl(),
  );

  Future<Rental> execute(Rental rental) {
    return repository.createRental(rental);
  }
}

