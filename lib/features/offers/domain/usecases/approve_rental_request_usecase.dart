import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/offers/domain/usecases/create_rental_usecase.dart';
import 'package:lendly_app/features/checkout/domain/usecases/create_payment_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApproveRentalRequestUseCase {
  final RentalRequestRepository rentalRequestRepository = RentalRequestRepositoryImpl(
    RentalRequestDataSourceImpl(),
  );
  final CreateRentalUseCase createRentalUseCase = CreateRentalUseCase();
  final CreatePaymentUseCase createPaymentUseCase = CreatePaymentUseCase();

  Future<RentalRequest> execute(
    String requestId,
    String pickupLocation,
    DateTime pickupAt,
  ) async {
    // Primero aprobar la solicitud
    final approvedRequest = await rentalRequestRepository.updateRentalRequestStatus(
      requestId,
      RentalRequestStatus.approved,
    );

    // Obtener el producto para crear el payment
    final productResponse = await Supabase.instance.client
        .from('items')
        .select()
        .eq('id', approvedRequest.productId)
        .single();
    final product = Product.fromJson(productResponse);

    // Crear el rental con la información de recogida
    final rental = Rental(
      rentalRequestId: approvedRequest.id!,
      productId: approvedRequest.productId,
      borrowerUserId: approvedRequest.borrowerUserId,
      pickupLocation: pickupLocation,
      pickupAt: pickupAt,
      status: RentalStatus.active,
      createdAt: DateTime.now(),
    );

    final createdRental = await createRentalUseCase.execute(rental);

    // Crear el payment después de crear el rental
    await createPaymentUseCase.execute(
      rentalId: createdRental.id!,
      ownerUserId: product.ownerId,
      borrowerUserId: approvedRequest.borrowerUserId,
      rentalRequest: approvedRequest,
      product: product,
    );

    return approvedRequest;
  }
}

