import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/product/data/source/product_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetRentedProductsUseCase {
  final RentalRepository rentalRepository;
  final RentalRequestRepository rentalRequestRepository;
  final ProductDataSource productDataSource;

  GetRentedProductsUseCase({
    RentalRepository? rentalRepository,
    RentalRequestRepository? rentalRequestRepository,
    ProductDataSource? productDataSource,
  })  : rentalRepository = rentalRepository ??
            RentalRepositoryImpl(RentalDataSourceImpl()),
        rentalRequestRepository = rentalRequestRepository ??
            RentalRequestRepositoryImpl(RentalRequestDataSourceImpl()),
        productDataSource = productDataSource ?? ProductDataSourceImpl();

  // Para borrower: obtener sus rentals activos
  Future<List<RentedProductData>> executeForBorrower(String borrowerId) async {
    final rentals = await rentalRepository.getRentalsByBorrower(borrowerId, status: 'ACTIVE');
    return await _buildRentedProductDataList(rentals, isBorrower: true);
  }

  // Para lender: obtener rentals de sus productos
  Future<List<RentedProductData>> executeForLender(String lenderId) async {
    final rentals = await rentalRepository.getRentalsByLender(lenderId, status: 'ACTIVE');
    return await _buildRentedProductDataList(rentals, isBorrower: false);
  }

  Future<List<RentedProductData>> _buildRentedProductDataList(
    List<Rental> rentals, {
    required bool isBorrower,
  }) async {
    final List<RentedProductData> result = [];

    for (var rental in rentals) {
      final rentalRequest = await rentalRequestRepository.getRentalRequestById(rental.rentalRequestId);
      if (rentalRequest == null) continue;

      // Obtener producto
      final productResponse = await Supabase.instance.client
          .from('items')
          .select()
          .eq('id', rental.productId)
          .maybeSingle();
      if (productResponse == null) continue;
      final product = Product.fromJson(productResponse);

      // Para borrower: obtener el dueño (owner)
      // Para lender: obtener el borrower
      final otherUserId = isBorrower ? product.ownerId : rental.borrowerUserId;
      final otherUser = await productDataSource.getOwnerInfo(otherUserId);
      if (otherUser == null) continue;

      result.add(RentedProductData(
        rental: rental,
        rentalRequest: rentalRequest,
        product: product,
        otherUser: otherUser,
      ));
    }

    return result;
  }
}

// Clase helper para agrupar la información necesaria para la UI
class RentedProductData {
  final Rental rental;
  final RentalRequest rentalRequest;
  final Product product;
  final AppUser otherUser;

  RentedProductData({
    required this.rental,
    required this.rentalRequest,
    required this.product,
    required this.otherUser,
  });

  DateTime get dueDate => rentalRequest.endDate;
  DateTime get startDate => rentalRequest.startDate;

  bool get isLate {
    return DateTime.now().isAfter(dueDate) && rental.status == RentalStatus.active;
  }

  int get lateDays {
    if (!isLate) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  int get dailyExtraCents {
    return (product.pricePerDayCents * 0.5).round(); // 50% extra por día
  }

  int get totalLateCharge => lateDays * dailyExtraCents;
}

