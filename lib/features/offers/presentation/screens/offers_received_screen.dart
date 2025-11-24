import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/offers/data/source/offers_data_source.dart';
import 'package:lendly_app/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_offers_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/approve_offer_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/reject_offer_usecase.dart';
import 'package:lendly_app/features/offers/presentation/bloc/offers_received_bloc.dart';
import 'package:lendly_app/features/offers/domain/models/offer.dart';

class OffersReceivedScreen extends StatelessWidget {
  const OffersReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersReceivedBloc(
        getUseCase: GetReceivedOffersUseCase(
          OffersRepositoryImpl(OffersDataSource()),
        ),
        approveUseCase: ApproveOfferUseCase(
          OffersRepositoryImpl(OffersDataSource()),
        ),
        rejectUseCase: RejectOfferUseCase(
          OffersRepositoryImpl(OffersDataSource()),
        ),
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
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OffersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OffersError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          final offers = _extractOffers(state);
          if (offers.isEmpty) {
            return const Center(child: Text('No hay solicitudes por ahora'));
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

  List<Offer> _extractOffers(OffersReceivedState state) {
    if (state is OffersLoaded) return state.offers;
    if (state is OfferActionInProgress) return state.current;
    if (state is OfferActionSuccess) return state.updated;
    return [];
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (offer.status) {
      OfferStatus.pending => const Color(0xFF555879),
      OfferStatus.approved => Colors.green,
      OfferStatus.rejected => Colors.red,
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
          )
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    offer.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Solicitante: ${offer.renter.name}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Periodo: ${_formatDate(offer.startDate)} - ${_formatDate(offer.endDate)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
            ),
            if (offer.pickupPoint != null) ...[
              const SizedBox(height: 4),
              Text(
                'Punto de recogida: ${offer.pickupPoint}',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navegar a chat
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: const Color(0xFF555879),
                ),
                const SizedBox(width: 8),
                if (offer.status == OfferStatus.pending) ...[
                  ElevatedButton(
                    onPressed: () => _showApproveDialog(context, offer.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF555879),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aprobar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => context
                        .read<OffersReceivedBloc>()
                        .add(RejectOfferEvent(offer.id)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _showApproveDialog(BuildContext context, String offerId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Configurar punto de recogida'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ej: Entrada principal centro comercial',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<OffersReceivedBloc>().add(
                      ApproveOfferEvent(offerId, controller.text.trim()),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF555879),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
