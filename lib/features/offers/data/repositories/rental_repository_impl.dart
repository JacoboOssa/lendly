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
  Future<Rental?> getRentalById(String rentalId) {
    return dataSource.getRentalById(rentalId);
  }

  @override
  Future<Rental> updateRentalStatus(String rentalId, RentalStatus status) {
    return dataSource.updateRentalStatus(rentalId, status);
  }

  @override
  Future<List<Rental>> getRentalsByBorrower(String borrowerId, {String? status}) {
    return dataSource.getRentalsByBorrower(borrowerId, status: status);
  }

  @override
  Future<List<Rental>> getRentalsByLender(String lenderId, {String? status}) {
    return dataSource.getRentalsByLender(lenderId, status: status);
  }

  @override
  Future<List<Rental>> getRentalsByProduct(String productId) {
    return dataSource.getRentalsByProduct(productId);
  }
}

