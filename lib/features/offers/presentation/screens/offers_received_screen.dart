import 'package:flutter/material.dart';

// Modelo simple para mock
class OfferMock {
  final String id;
  final String productTitle;
  final String renterName;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // PENDING, APPROVED, REJECTED
  final String? pickupPoint;
  OfferMock({
    required this.id,
    required this.productTitle,
    required this.renterName,
    required this.startDate,
    required this.endDate,
    this.status = 'PENDING',
    this.pickupPoint,
  });
}

class OffersReceivedScreen extends StatelessWidget {
  const OffersReceivedScreen({super.key});

  List<OfferMock> _mock() => [
    OfferMock(
      id: '1',
      productTitle: 'Palo de hockey',
      renterName: 'Sebastian Castillo',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    OfferMock(
      id: '2',
      productTitle: 'Kit de sonido',
      renterName: 'Juan Brown',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 10)),
    ),
    OfferMock(
      id: '3',
      productTitle: 'Cámara DSLR',
      renterName: 'Laura Pérez',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      status: 'APPROVED',
      pickupPoint: 'Entrada centro comercial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final data = _mock();
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
          'Solicitudes recibidas',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final offer = data[index];
          return _OfferCard(offer: offer);
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferMock offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (offer.status) {
      'PENDING' => const Color(0xFF555879),
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      _ => const Color(0xFF555879),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.productTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    offer.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solicitante: ${offer.renterName}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 4),
            Text(
              'Periodo: ${_fmt(offer.startDate)} - ${_fmt(offer.endDate)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
            ),
            if (offer.pickupPoint != null) ...[
              const SizedBox(height: 4),
              Text(
                'Punto de recogida: ${offer.pickupPoint}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {}, // TODO chat
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: const Color(0xFF555879),
                ),
                const SizedBox(width: 8),
                if (offer.status == 'PENDING') ...[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF555879),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Aprobar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ] else if (offer.status == 'APPROVED') ...[
                  OutlinedButton(
                    onPressed: () {}, // TODO pago
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF555879),
                      side: const BorderSide(color: Color(0xFF555879)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Pagar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
