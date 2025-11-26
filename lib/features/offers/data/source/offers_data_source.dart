import 'package:lendly_app/features/offers/domain/models/offer.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/product.dart';

/// DataSource mock temporal. Sustituir luego por Supabase.
class OffersDataSource {
  final List<Offer> _offers = [
    Offer(
      id: '1',
      product: Product(
        id: 'p1',
        ownerId: 'owner1',
        title: 'Palo de hockey',
        pricePerDayCents: 3000,
        city: 'Bogotá',
        address: 'Calle 123 #45-67',
      ),
      renter: AppUser(
        id: 'u2',
        name: 'Sebastian Castillo',
        email: 'sebastian@example.com',
        role: 'renter',
        phone: '+57 3000000000',
        address: 'Carrera 10 #20-30',
        city: 'Bogotá',
      ),
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Offer(
      id: '2',
      product: Product(
        id: 'p2',
        ownerId: 'owner1',
        title: 'Kit de sonido',
        pricePerDayCents: 7500,
        city: 'Medellín',
        address: 'Av. Principal 55',
      ),
      renter: AppUser(
        id: 'u3',
        name: 'Juan Brown',
        email: 'juan@example.com',
        role: 'renter',
        phone: '+57 3100000000',
        address: 'Calle 8 #12-34',
        city: 'Medellín',
      ),
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

  Future<List<Offer>> fetchOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_offers);
  }

  Future<Offer> approve(String id, String pickupPoint) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _offers.indexWhere((o) => o.id == id);
    if (index == -1) throw Exception('Offer not found');
    _offers[index] = _offers[index].copyWith(
      status: OfferStatus.approved,
      pickupPoint: pickupPoint,
    );
    return _offers[index];
  }

  Future<void> reject(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _offers.indexWhere((o) => o.id == id);
    if (index == -1) throw Exception('Offer not found');
    _offers[index] = _offers[index].copyWith(status: OfferStatus.rejected);
  }
}
