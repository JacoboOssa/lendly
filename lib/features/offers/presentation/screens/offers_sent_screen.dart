import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/offers/presentation/bloc/offers_sent_bloc.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_usecase.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/profile/presentation/screens/profile_detail_screen.dart';

class OffersSentScreen extends StatelessWidget {
  const OffersSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersSentBloc(
        getUseCase: GetSentRentalRequestsUseCase(),
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase(),
      )..add(LoadSentOffersEvent()),
      child: const _OffersSentView(),
    );
  }
}

class _OffersSentView extends StatelessWidget {
  const _OffersSentView();

  @override
  Widget build(BuildContext context) {
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
          'Mis solicitudes',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<OffersSentBloc, OffersSentState>(
        listener: (context, state) {
          if (state is OffersSentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersSentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OffersSentError) {
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
          final offers = _extractOffers(state);
          if (offers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Color(0xFF9E9E9E),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No has enviado solicitudes',
                    style: TextStyle(
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
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _SentOfferCard(offer: offer);
            },
          );
        },
      ),
    );
  }

  List<SentRentalRequestView> _extractOffers(OffersSentState state) {
    if (state is OffersSentLoaded) return state.offers;
    return [];
  }
}

class _SentOfferCard extends StatelessWidget {
  final SentRentalRequestView offer;

  const _SentOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(offer.request.status);
    final statusText = _getStatusText(offer.request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                    offer.product.title,
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
                    color: statusColor.withValues(alpha: 0.1),
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Dueño: ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileDetailScreen(userId: offer.owner.id),
                      ),
                    );
                  },
                  child: Text(
                    offer.owner.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B5670),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Periodo: ${_formatDate(offer.request.startDate)} - ${_formatDate(offer.request.endDate)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
            ),
            if (offer.request.status == RentalRequestStatus.approved && offer.rental != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF5B5670)),
                        const SizedBox(width: 4),
                        const Text(
                          'Punto de recogida:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B5670),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.rental!.pickupLocation,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Color(0xFF5B5670)),
                        const SizedBox(width: 4),
                        const Text(
                          'Hora de recogida:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B5670),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(offer.rental!.pickupAt),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RentalRequestStatus status) {
    switch (status) {
      case RentalRequestStatus.pending:
        return const Color(0xFF5B5670);
      case RentalRequestStatus.approved:
        return Colors.green;
      case RentalRequestStatus.rejected:
        return Colors.red;
      case RentalRequestStatus.cancelled:
        return Colors.orange;
      case RentalRequestStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText(RentalRequestStatus status) {
    switch (status) {
      case RentalRequestStatus.pending:
        return 'PENDIENTE';
      case RentalRequestStatus.approved:
        return 'APROBADA';
      case RentalRequestStatus.rejected:
        return 'RECHAZADA';
      case RentalRequestStatus.cancelled:
        return 'CANCELADA';
      case RentalRequestStatus.expired:
        return 'EXPIRADA';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

