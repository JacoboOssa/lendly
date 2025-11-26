import 'package:lendly_app/features/offers/domain/models/offer.dart';
import 'package:lendly_app/features/offers/domain/repositories/offers_repository.dart';

class ApproveOfferUseCase {
  final OffersRepository repository;
  ApproveOfferUseCase(this.repository);

  Future<Offer> call(String offerId, String pickupPoint) =>
      repository.approveOffer(offerId, pickupPoint);
}
