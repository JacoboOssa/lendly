import 'package:lendly_app/domain/model/rental.dart';

abstract class RentalRepository {
  Future<Rental> createRental(Rental rental);
  Future<Rental?> getRentalByRequestId(String rentalRequestId);
  Future<List<Rental>> getRentalsByBorrower(String borrowerId);
  Future<List<Rental>> getRentalsByProduct(String productId);
}

