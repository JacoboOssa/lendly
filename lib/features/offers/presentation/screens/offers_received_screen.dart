import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/offers/presentation/bloc/offers_received_bloc.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/approve_rental_request_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/reject_rental_request_usecase.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';

class OffersReceivedScreen extends StatelessWidget {
  const OffersReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersReceivedBloc(
        getUseCase: GetReceivedRentalRequestsUseCase(),
        approveUseCase: ApproveRentalRequestUseCase(),
        rejectUseCase: RejectRentalRequestUseCase(),
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase(),
      )..add(LoadOffersEvent()),
      child: const _OffersView(),
    );
  }
}

class _OffersView extends StatelessWidget {
  const _OffersView();

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
          'Solicitudes recibidas',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<OffersReceivedBloc, OffersReceivedState>(
        listener: (context, state) {
          if (state is OfferActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is OffersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B5670)),
              ),
            );
          }
          if (state is OffersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OffersReceivedBloc>().add(LoadOffersEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5670),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
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
                    'No hay solicitudes por ahora',
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
              return _OfferCard(offer: offer);
            },
          );
        },
      ),
    );
  }

  List<RentalRequestView> _extractOffers(OffersReceivedState state) {
    if (state is OffersLoaded) return state.offers;
    if (state is OfferActionInProgress) return state.current;
    if (state is OfferActionSuccess) return state.updated;
    return [];
  }
}

class _OfferCard extends StatelessWidget {
  final RentalRequestView offer;
  const _OfferCard({required this.offer});

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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solicitante: ${offer.borrower.name}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 4),
            Text(
              'Periodo: ${_formatDate(offer.request.startDate)} - ${_formatDate(offer.request.endDate)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navegar a chat
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: const Color(0xFF5B5670),
                ),
                const SizedBox(width: 8),
                if (offer.request.status == RentalRequestStatus.pending) ...[
                  ElevatedButton(
                    onPressed: () => _showApproveDialog(context, offer.request.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5670),
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
                    onPressed: () => context.read<OffersReceivedBloc>().add(
                      RejectOfferEvent(offer.request.id!),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ],
              ],
            ),
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

  void _showApproveDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Aprobar solicitud',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas aprobar esta solicitud de alquiler?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6D6D6D),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<OffersReceivedBloc>().add(
                  ApproveOfferEvent(requestId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5670),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Aprobar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
