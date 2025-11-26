import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_request_repository.dart';
import 'package:lendly_app/features/offers/domain/usecases/create_rental_usecase.dart';

class ApproveRentalRequestUseCase {
  final RentalRequestRepository rentalRequestRepository = RentalRequestRepositoryImpl(
    RentalRequestDataSourceImpl(),
  );
  final CreateRentalUseCase createRentalUseCase = CreateRentalUseCase();

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

    // Luego crear el rental con la información de recogida
    final rental = Rental(
      rentalRequestId: approvedRequest.id!,
      productId: approvedRequest.productId,
      borrowerUserId: approvedRequest.borrowerUserId,
      pickupLocation: pickupLocation,
      pickupAt: pickupAt,
      status: RentalStatus.active,
      createdAt: DateTime.now(),
    );

    await createRentalUseCase.execute(rental);

    return approvedRequest;
  }
}

