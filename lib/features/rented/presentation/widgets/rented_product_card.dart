import 'package:flutter/material.dart';
import 'package:lendly_app/features/rented/presentation/screens/rented_products_screen.dart';

class RentedProductCard extends StatelessWidget {
  final RentedProduct item;
  final VoidCallback onChat;
  final VoidCallback onReturn;
  final VoidCallback? onPay;
  const RentedProductCard({
    super.key,
    required this.item,
    required this.onChat,
    required this.onReturn,
    this.onPay,
  });

  Color get _primary => const Color(0xFF555879);
  Color get _bg => const Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      RentalStatus.pending => _primary,
      RentalStatus.approved => Colors.green,
      RentalStatus.overdue => Colors.red,
    };

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
                _thumbPlaceholder(),
                const SizedBox(width: 12),
                Expanded(child: _info(statusColor)),
                _statusBadge(statusColor),
              ],
            ),
            const SizedBox(height: 12),
            _progressBar(progress, statusColor),
            const SizedBox(height: 8),
            if (item.isLate) _lateInfo(),
            Row(
              children: [
                IconButton(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: _primary,
                ),
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
                const SizedBox(width: 12),
                if (item.status == RentalStatus.approved && onPay != null)
                  OutlinedButton(
                    onPressed: onPay,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Pagar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
          item.product.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dueño: ${item.ownerName}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 4),
        Text(
          'Límite: ${_formatDate(item.dueDate)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
        ),
      ],
    );
  }

  Widget _statusBadge(Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item.status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _progressBar(double progress, Color statusColor) {
    final isLate = item.isLate;
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
              ? 'Retrasado desde ${_formatDate(item.dueDate)}'
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

  Widget _lateInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Retrasado: ${item.lateDays} día(s) - Cargo extra: ${(item.totalLateCharge / 100).toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _computeProgress() {
    final total = item.dueDate.difference(item.startDate).inSeconds;
    final elapsed = DateTime.now().difference(item.startDate).inSeconds;
    if (total <= 0) return 0;
    return elapsed / total;
  }

  int _remainingDays() {
    final diff = item.dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
