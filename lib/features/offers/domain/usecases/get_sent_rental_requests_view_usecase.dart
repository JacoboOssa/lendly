import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_usecase.dart';
import 'package:lendly_app/features/product/domain/repositories/product_repository.dart';

class SentRentalRequestView {
  final RentalRequest request;
  final Product product;
  final AppUser owner;
  final Rental? rental;

  SentRentalRequestView({
    required this.request,
    required this.product,
    required this.owner,
    this.rental,
  });
}

class GetSentRentalRequestsViewUseCase {
  final GetSentRentalRequestsUseCase getRentalRequestsUseCase;
  final ProductRepository productRepository;
  final RentalRepository rentalRepository;

  GetSentRentalRequestsViewUseCase({
    required this.getRentalRequestsUseCase,
    required this.productRepository,
    required this.rentalRepository,
  });

  Future<List<SentRentalRequestView>> execute(String borrowerId) async {
    final requests = await getRentalRequestsUseCase.execute(borrowerId);

    final List<SentRentalRequestView> views = [];
    for (final request in requests) {
      try {
        // Obtener producto
        final product = await productRepository.getProductById(request.productId);

        // Obtener dueño del producto
        final owner = await productRepository.getOwnerInfo(product.ownerId);
        if (owner == null) continue;

        // Obtener rental si la solicitud está aprobada
        Rental? rental;
        if (request.status == RentalRequestStatus.approved && request.id != null) {
          try {
            rental = await rentalRepository.getRentalByRequestId(request.id!);
          } catch (e) {
            rental = null;
          }
        }

        views.add(SentRentalRequestView(
          request: request,
          product: product,
          owner: owner,
          rental: rental,
        ));
      } catch (e) {
        continue;
      }
    }

    return views;
  }
}

