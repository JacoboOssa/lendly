import 'package:lendly_app/features/offers/domain/repositories/offers_repository.dart';

class RejectOfferUseCase {
  final OffersRepository repository;
  RejectOfferUseCase(this.repository);

  Future<void> call(String offerId) => repository.rejectOffer(offerId);
}
