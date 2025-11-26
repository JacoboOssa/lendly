import 'package:lendly_app/domain/model/rental.dart';


abstract class RentalRepository {
  Future<Rental> createRental(Rental rental);
  Future<Rental?> getRentalByRequestId(String rentalRequestId);
  Future<Rental?> getRentalById(String rentalId);
  Future<Rental> updateRentalStatus(String rentalId, RentalStatus status);
  Future<List<Rental>> getRentalsByBorrower(String borrowerId, {String? status});
  Future<List<Rental>> getRentalsByProduct(String productId);
  Future<List<Rental>> getRentalsByLender(String lenderId, {String? status});
}

