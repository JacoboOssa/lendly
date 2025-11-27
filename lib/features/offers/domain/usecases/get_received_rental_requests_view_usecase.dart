import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_usecase.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class RentalRequestView {
  final RentalRequest request;
  final Product product;
  final AppUser borrower;
  final Rental? rental;

  RentalRequestView({
    required this.request,
    required this.product,
    required this.borrower,
    this.rental,
  });
}

class GetReceivedRentalRequestsViewUseCase {
  final GetReceivedRentalRequestsUseCase getRentalRequestsUseCase;
  final ProductRepository productRepository;
  final RentalRepository rentalRepository;

  GetReceivedRentalRequestsViewUseCase({
    required this.getRentalRequestsUseCase,
    required this.productRepository,
    required this.rentalRepository,
  });

  Future<List<RentalRequestView>> execute(String ownerId) async {
    final requests = await getRentalRequestsUseCase.execute(ownerId);

    final List<RentalRequestView> views = [];
    for (final request in requests) {
      try {
        // Obtener producto
        final product = await productRepository.getProductById(request.productId);

        // Obtener usuario que solicita
        final borrower = await productRepository.getOwnerInfo(request.borrowerUserId);
        if (borrower == null) continue;

        // Obtener rental si la solicitud está aprobada
        Rental? rental;
        if (request.status == RentalRequestStatus.approved && request.id != null) {
          try {
            rental = await rentalRepository.getRentalByRequestId(request.id!);
          } catch (e) {
            rental = null;
          }
        }

        views.add(RentalRequestView(
          request: request,
          product: product,
          borrower: borrower,
          rental: rental,
        ));
      } catch (e) {
        continue;
      }
    }

    return views;
  }
}

