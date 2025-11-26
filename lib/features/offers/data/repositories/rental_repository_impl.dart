import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';

class RentalRepositoryImpl implements RentalRepository {
  final RentalDataSource dataSource;

  RentalRepositoryImpl(this.dataSource);

  @override
  Future<Rental> createRental(Rental rental) {
    return dataSource.createRental(rental);
  }

  @override
  Future<Rental?> getRentalByRequestId(String rentalRequestId) {
    return dataSource.getRentalByRequestId(rentalRequestId);
  }

  @override
  Future<List<Rental>> getRentalsByBorrower(String borrowerId) {
    return dataSource.getRentalsByBorrower(borrowerId);
  }

  @override
  Future<List<Rental>> getRentalsByProduct(String productId) {
    return dataSource.getRentalsByProduct(productId);
  }
}

