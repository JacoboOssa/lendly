import 'package:lendly_app/features/offers/domain/models/offer.dart';

abstract class OffersRepository {
  Future<List<Offer>> getReceivedOffers();
  Future<Offer> approveOffer(String offerId, String pickupPoint);
  Future<void> rejectOffer(String offerId);
}
