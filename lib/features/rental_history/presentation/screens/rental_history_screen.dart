import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lendly_app/core/services/user_session_service.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:lendly_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:lendly_app/features/profile/presentation/screens/profile_detail_screen.dart';
import 'package:lendly_app/features/rental_history/presentation/bloc/rental_history_bloc.dart';
import 'package:lendly_app/features/return/presentation/screens/return_screen.dart';

class RentalHistoryScreen extends StatelessWidget {
  const RentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentalHistoryBloc()..add(LoadRentalHistoryEvent()),
      child: const _RentalHistoryView(),
    );
  }
}

class _RentalHistoryView extends StatelessWidget {
  const _RentalHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: UserSessionService().isBorrower
            ? 'Historial de alquileres'
            : 'Historial de préstamos',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<RentalHistoryBloc, RentalHistoryState>(
          builder: (context, state) {
            if (state is RentalHistoryLoading) {
              return const Center(
                child: LoadingSpinner(),
              );
            }

            if (state is RentalHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is RentalHistoryLoaded) {
              if (state.rentals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64,
                        color: Color(0xFF9E9E9E),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.isBorrower
                            ? 'No tienes historial de alquileres'
                            : 'No tienes historial de préstamos',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.rentals.length,
                itemBuilder: (context, index) {
                  final rentalData = state.rentals[index];
                  return _RentalHistoryCard(
                    rentalData: rentalData,
                    isBorrower: state.isBorrower,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }
}

class _RentalHistoryCard extends StatelessWidget {
  final RentalHistoryData rentalData;
  final bool isBorrower;

  const _RentalHistoryCard({
    required this.rentalData,
    required this.isBorrower,
  });

  Color get _primary => const Color(0xFF555879);
  Color get _bg => Colors.white;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCreatedDate(DateTime date) {
    return DateFormat('EEE d MMM yyyy', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = rentalData.rental.status == RentalStatus.completed
        ? _primary
        : (rentalData.isLate ? Colors.red : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                _productImage(),
                const SizedBox(width: 12),
                Expanded(child: _info(context, statusColor)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatDate(rentalData.startDate)} - ${_formatDate(rentalData.dueDate)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 4),
            Text(
              'Creado: ${_formatCreatedDate(rentalData.rental.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 8),
            _statusBadge(statusColor),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          otherUser: rentalData.otherUser,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: _primary,
                ),
                // Botón para calificar (solo para lender cuando está completado y no ha calificado)
                if (!isBorrower &&
                    rentalData.rental.status == RentalStatus.completed &&
                    rentalData.ownerRating == null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/rating/renter',
                          arguments: {
                            'rentalId': rentalData.rental.id!,
                            'borrowerUserId': rentalData.otherUser.id,
                            'renterName': rentalData.otherUser.name,
                          },
                        ).then((_) {
                          // Recargar después de calificar
                          if (context.mounted) {
                            context.read<RentalHistoryBloc>().add(LoadRentalHistoryEvent());
                          }
                        });
                      },
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text(
                        'Calificar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage() {
    if (rentalData.product.photoUrl != null && rentalData.product.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          rentalData.product.photoUrl!,
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
      child: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
    );
  }

  Widget _info(BuildContext context, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rentalData.product.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              isBorrower ? 'Dueño: ' : 'Alquilador: ',
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileDetailScreen(userId: rentalData.otherUser.id),
                  ),
                );
              },
              child: Text(
                rentalData.otherUser.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(Color statusColor) {
    String statusText;
    if (rentalData.rental.status == RentalStatus.completed) {
      statusText = isBorrower ? 'DEVUELTO' : 'RECIBIDO';
    } else if (rentalData.isLate) {
      statusText = 'RETRASADO';
    } else if (rentalData.rental.status == RentalStatus.active) {
      statusText = 'ACTIVO';
    } else {
      statusText = 'PENDIENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
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
}

