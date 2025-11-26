import 'package:lendly_app/features/offers/domain/models/offer.dart';
import 'package:lendly_app/features/offers/domain/repositories/offers_repository.dart';

class GetReceivedOffersUseCase {
  final OffersRepository repository;
  GetReceivedOffersUseCase(this.repository);

  Future<List<Offer>> call() => repository.getReceivedOffers();
}
