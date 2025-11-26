import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/product/data/source/product_data_source.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';
import 'package:lendly_app/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:lendly_app/features/rating/data/source/rating_data_source.dart';
import 'package:lendly_app/features/rating/domain/repositories/rating_repository.dart';
import 'package:lendly_app/domain/model/rating.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetRentalHistoryUseCase {
  final RentalRepository rentalRepository;
  final RentalRequestRepository rentalRequestRepository;
  final ProductDataSource productDataSource;
  final PaymentRepository paymentRepository;
  final RatingRepository ratingRepository;

  GetRentalHistoryUseCase({
    RentalRepository? rentalRepository,
    RentalRequestRepository? rentalRequestRepository,
    ProductDataSource? productDataSource,
    PaymentRepository? paymentRepository,
    RatingRepository? ratingRepository,
  })  : rentalRepository = rentalRepository ??
            RentalRepositoryImpl(RentalDataSourceImpl()),
        rentalRequestRepository = rentalRequestRepository ??
            RentalRequestRepositoryImpl(RentalRequestDataSourceImpl()),
        productDataSource = productDataSource ?? ProductDataSourceImpl(),
        paymentRepository = paymentRepository ??
            PaymentRepositoryImpl(PaymentDataSourceImpl()),
        ratingRepository = ratingRepository ??
            RatingRepositoryImpl(RatingDataSourceImpl());

  // Para borrower: obtener todos sus rentals (activos y completados)
  Future<List<RentalHistoryData>> executeForBorrower(String borrowerId) async {
    final activeRentals = await rentalRepository.getRentalsByBorrower(borrowerId, status: 'ACTIVE');
    final completedRentals = await rentalRepository.getRentalsByBorrower(borrowerId, status: 'COMPLETED');
    final allRentals = [...activeRentals, ...completedRentals];
    return await _buildRentalHistoryDataList(allRentals, isBorrower: true);
  }

  // Para lender: obtener todos los rentals de sus productos (activos y completados)
  Future<List<RentalHistoryData>> executeForLender(String lenderId) async {
    final activeRentals = await rentalRepository.getRentalsByLender(lenderId, status: 'ACTIVE');
    final completedRentals = await rentalRepository.getRentalsByLender(lenderId, status: 'COMPLETED');
    final allRentals = [...activeRentals, ...completedRentals];
    return await _buildRentalHistoryDataList(allRentals, isBorrower: false, lenderId: lenderId);
  }

  Future<List<RentalHistoryData>> _buildRentalHistoryDataList(
    List<Rental> rentals, {
    required bool isBorrower,
    String? lenderId,
  }) async {
    final List<RentalHistoryData> result = [];

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

      // Obtener payment si existe
      final payment = await paymentRepository.getPaymentByRentalId(rental.id!);

      // Verificar si ya existe calificación del borrower para el dueño/producto
      // o del dueño para el borrower
      Rating? borrowerRating;
      Rating? ownerRating;
      Rating? productRating;
      
      if (isBorrower) {
        // Si es borrower, verificar si ya calificó al dueño y al producto
        borrowerRating = await ratingRepository.getRatingByRentalAndType(
          rental.id!,
          rental.borrowerUserId,
          RatingType.owner,
        );
        productRating = await ratingRepository.getRatingByRentalAndType(
          rental.id!,
          rental.borrowerUserId,
          RatingType.product,
        );
      } else {
        // Si es lender, verificar si ya calificó al borrower
        // lenderId es el ownerId del producto
        if (lenderId != null) {
          ownerRating = await ratingRepository.getRatingByRentalAndType(
            rental.id!,
            lenderId,
            RatingType.borrower,
          );
        }
      }

      result.add(RentalHistoryData(
        rental: rental,
        rentalRequest: rentalRequest,
        product: product,
        otherUser: otherUser,
        payment: payment,
        borrowerRating: borrowerRating,
        ownerRating: ownerRating,
        productRating: productRating,
      ));
    }

    return result;
  }
}

// Clase helper para agrupar la información necesaria para la UI del historial
class RentalHistoryData {
  final Rental rental;
  final RentalRequest rentalRequest;
  final Product product;
  final AppUser otherUser;
  final Payment? payment;
  final Rating? borrowerRating; // Calificación del borrower al owner
  final Rating? ownerRating; // Calificación del owner al borrower
  final Rating? productRating; // Calificación del borrower al producto

  RentalHistoryData({
    required this.rental,
    required this.rentalRequest,
    required this.product,
    required this.otherUser,
    this.payment,
    this.borrowerRating,
    this.ownerRating,
    this.productRating,
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

