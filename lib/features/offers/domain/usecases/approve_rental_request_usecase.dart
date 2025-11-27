import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class ApproveRentalRequestUseCase {
  final RentalRequestRepository rentalRequestRepository;
  final RentalRepository rentalRepository;
  final PaymentRepository paymentRepository;
  final ProductRepository productRepository;

  ApproveRentalRequestUseCase({
    required this.rentalRequestRepository,
    required this.rentalRepository,
    required this.paymentRepository,
    required this.productRepository,
  });

  Future<RentalRequest> execute(
    String requestId,
    String pickupLocation,
    DateTime pickupAt,
  ) async {
    // 1. Obtener y actualizar el status de la solicitud a APPROVED
    final approvedRequest = await rentalRequestRepository.updateRentalRequestStatus(
      requestId,
      RentalRequestStatus.approved,
    );

    // 3. Obtener el producto
    final product = await productRepository.getProductById(approvedRequest.productId);

    // 4. Construir y crear el rental (lógica de negocio en el use case)
    final rental = Rental(
      rentalRequestId: approvedRequest.id!,
      productId: approvedRequest.productId,
      borrowerUserId: approvedRequest.borrowerUserId,
      pickupLocation: pickupLocation,
      pickupAt: pickupAt,
      status: RentalStatus.active,
      createdAt: DateTime.now(),
    );
    final createdRental = await rentalRepository.createRental(rental);

    // 5. Construir y crear el payment (lógica de negocio en el use case)
    final numberOfDays = approvedRequest.endDate.difference(approvedRequest.startDate).inDays + 1;
    final dailyPrice = product.pricePerDayCents / 100.0;
    final totalAmount = dailyPrice * numberOfDays;

    final payment = Payment(
      rentalId: createdRental.id!,
      ownerUserId: product.ownerId,
      borrowerUserId: approvedRequest.borrowerUserId,
      startDate: approvedRequest.startDate,
      endDate: approvedRequest.endDate,
      dailyPrice: dailyPrice,
      totalAmount: totalAmount,
      paid: false,
      numberOfDays: numberOfDays,
      createdAt: DateTime.now(),
    );
    await paymentRepository.createPayment(payment);

    return approvedRequest;
  }
}

