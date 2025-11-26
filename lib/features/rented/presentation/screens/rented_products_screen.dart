import 'package:flutter/material.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/rented/presentation/widgets/rented_product_card.dart';

enum RentalStatus { pending, approved, overdue }

class RentedProduct {
  final Product product;
  final String ownerName;
  final DateTime dueDate; // fecha límite para devolver
  final DateTime startDate;
  final RentalStatus status;
  final int dailyExtraCents; // cargo extra por día de retraso

  RentedProduct({
    required this.product,
    required this.ownerName,
    required this.startDate,
    required this.dueDate,
    required this.status,
    this.dailyExtraCents = 0,
  });

  bool get isLate => status == RentalStatus.overdue;
  int get lateDays {
    if (!isLate) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  int get totalLateCharge => lateDays * dailyExtraCents;
}

class RentedProductsScreen extends StatelessWidget {
  const RentedProductsScreen({super.key});

  // Mock temporal (frontend solamente)
  List<RentedProduct> _mockData() {
    return [
      RentedProduct(
        product: Product(
          id: 'rp1',
          ownerId: 'lender1',
          title: 'Palo de hockey',
          pricePerDayCents: 3000,
          city: 'Bogotá',
          address: 'Calle 12 #3-45',
        ),
        ownerName: 'Sebastian Castillo',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: RentalStatus.pending,
      ),
      RentedProduct(
        product: Product(
          id: 'rp2',
          ownerId: 'lender2',
          title: 'Kit de sonido',
          pricePerDayCents: 7500,
          city: 'Medellín',
          address: 'Av. Principal 55',
        ),
        ownerName: 'Juan Brown',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: RentalStatus.overdue,
        dailyExtraCents: 15000,
      ),
      RentedProduct(
        product: Product(
          id: 'rp3',
          ownerId: 'lender3',
          title: 'Cámara DSLR',
          pricePerDayCents: 10000,
          city: 'Cali',
          address: 'Calle 8 #20',
        ),
        ownerName: 'Laura Pérez',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: RentalStatus.approved,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _mockData();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Productos alquilados',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return RentedProductCard(
            item: item,
            onChat: () {
              /* TODO chat */
            },
            onReturn: () => Navigator.pushNamed(context, '/return-product'),
            onPay: item.status == RentalStatus.approved
                ? () => Navigator.pushNamed(context, '/checkout')
                : null,
          );
        },
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2C2C2C),
      ),
      body: const Center(child: Text('Pantalla de pago (placeholder)')),
    );
  }
}

class ReturnProductScreen extends StatelessWidget {
  const ReturnProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devolución'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2C2C2C),
      ),
      body: const Center(child: Text('Proceso de devolución (placeholder)')),
    );
  }
}
