import 'package:flutter/material.dart';
import 'package:lendly_app/features/rented/domain/usecases/get_rented_products_usecase.dart';
import 'package:lendly_app/domain/model/rental.dart';

class RentedProductCard extends StatelessWidget {
  final RentedProductData productData;
  final bool isBorrower;
  final VoidCallback onChat;
  final VoidCallback onReturn;
  final VoidCallback? onPay;

  const RentedProductCard({
    super.key,
    required this.productData,
    required this.isBorrower,
    required this.onChat,
    required this.onReturn,
    this.onPay,
  });

  Color get _primary => const Color(0xFF555879);
  Color get _bg => const Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    final statusColor = productData.isLate
        ? Colors.red
        : (productData.rental.status == RentalStatus.active
            ? Colors.green
            : _primary);

    final progress = _computeProgress();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _bg,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _productImage(),
                const SizedBox(width: 12),
                Expanded(child: _info(statusColor)),
                _statusBadge(statusColor),
              ],
            ),
            const SizedBox(height: 12),
            _remainingDaysInfo(statusColor),
            const SizedBox(height: 8),
            if (productData.isLate) _lateInfo(),
            Row(
              children: [
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: _primary,
                ),
                if (isBorrower) ...[
                  // Si no ha pagado, mostrar solo el botón de pagar
                  if (productData.payment != null && !productData.payment!.paid) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Pagar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Si ya pagó, mostrar botón de devolución
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Devolución',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage() {
    if (productData.product.photoUrl != null && productData.product.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          productData.product.photoUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _thumbPlaceholder(),
        ),
      );
    }
    return _thumbPlaceholder();
  }

  Widget _thumbPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.photo_camera_outlined, color: Color(0xFF5B5670)),
    );
  }

  Widget _info(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productData.product.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isBorrower
              ? 'Dueño: ${productData.otherUser.name}'
              : 'Alquilador: ${productData.otherUser.name}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatDate(productData.startDate)} - ${_formatDate(productData.dueDate)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
        ),
      ],
    );
  }

  Widget _statusBadge(Color statusColor) {
    String statusText;
    if (productData.isLate) {
      statusText = 'RETRASADO';
    } else if (productData.rental.status == RentalStatus.active) {
      statusText = 'APROBADO';
    } else {
      statusText = 'PENDIENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _progressBar(double progress, Color statusColor) {
    final isLate = productData.isLate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: isLate ? 1 : progress.clamp(0, 1),
          backgroundColor: const Color(0xFFE0E0E0),
          valueColor: AlwaysStoppedAnimation(isLate ? Colors.red : statusColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          isLate
              ? 'Retrasado desde ${_formatDate(productData.dueDate)}'
              : 'Progreso: ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% (${_remainingDays()} día(s) restantes)',
          style: TextStyle(
            fontSize: 11,
            color: isLate ? Colors.red : const Color(0xFF555555),
            fontWeight: isLate ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _remainingDaysInfo(Color statusColor) {
    final isLate = productData.isLate;
    final remainingDays = _remainingDays();
    
    return Text(
      isLate
          ? 'Retrasado desde ${_formatDate(productData.dueDate)}'
          : remainingDays > 0
              ? '${remainingDays} día(s) restantes'
              : 'Vence hoy',
      style: TextStyle(
        fontSize: 13,
        color: isLate ? Colors.red : const Color(0xFF555555),
        fontWeight: isLate ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _lateInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Retrasado: ${productData.lateDays} día(s) - Cargo extra: \$${(productData.totalLateCharge / 100).toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _computeProgress() {
    final total = productData.dueDate.difference(productData.startDate).inSeconds;
    final elapsed = DateTime.now().difference(productData.startDate).inSeconds;
    if (total <= 0) return 0;
    return elapsed / total;
  }

  int _remainingDays() {
    final diff = productData.dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
