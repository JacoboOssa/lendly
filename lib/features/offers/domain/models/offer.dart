import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/product.dart';

enum OfferStatus { pending, approved, rejected }

class Offer {
  final String id;
  final Product product;
  final AppUser renter; // usuario que quiere alquilar
  final DateTime startDate;
  final DateTime endDate;
  final OfferStatus status;
  final String? pickupPoint; // definido al aprobar

  Offer({
    required this.id,
    required this.product,
    required this.renter,
    required this.startDate,
    required this.endDate,
    this.status = OfferStatus.pending,
    this.pickupPoint,
  });

  Offer copyWith({OfferStatus? status, String? pickupPoint}) {
    return Offer(
      id: id,
      product: product,
      renter: renter,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      pickupPoint: pickupPoint ?? this.pickupPoint,
    );
  }
}
