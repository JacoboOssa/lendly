import 'package:lendly_app/features/offers/domain/models/offer.dart';
import 'package:lendly_app/features/offers/domain/repositories/offers_repository.dart';
import 'package:lendly_app/features/offers/data/source/offers_data_source.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersDataSource dataSource;
  OffersRepositoryImpl(this.dataSource);

  @override
  Future<List<Offer>> getReceivedOffers() => dataSource.fetchOffers();

  @override
  Future<Offer> approveOffer(String offerId, String pickupPoint) =>
      dataSource.approve(offerId, pickupPoint);

  @override
  Future<void> rejectOffer(String offerId) => dataSource.reject(offerId);
}
