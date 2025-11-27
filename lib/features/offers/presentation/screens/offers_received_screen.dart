import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:lendly_app/features/offers/presentation/bloc/offers_received_bloc.dart';
import 'package:lendly_app/features/profile/presentation/screens/profile_detail_screen.dart';

class OffersReceivedScreen extends StatelessWidget {
  const OffersReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersReceivedBloc()..add(LoadOffersEvent()),
      child: const _OffersView(),
    );
  }
}

class _OffersView extends StatefulWidget {
  const _OffersView();

  @override
  State<_OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<_OffersView> {
  bool _isLoadingDialogShown = false;

  void _showLoadingDialog(BuildContext context) {
    if (!_isLoadingDialogShown && context.mounted) {
      _isLoadingDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingSpinner(size: 40),
                    SizedBox(height: 16),
                    Text(
                      'Aprobando solicitud...',
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _hideLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShown && context.mounted) {
      _isLoadingDialogShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void dispose() {
    // Cerrar el diálogo si el widget se desmonta mientras está mostrando el diálogo
    if (_isLoadingDialogShown && mounted) {
      _isLoadingDialogShown = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Solicitudes recibidas',
      ),
      body: BlocConsumer<OffersReceivedBloc, OffersReceivedState>(
        listener: (context, state) {
          if (state is OfferActionInProgress) {
            _showLoadingDialog(context);
          } else if (state is OffersLoaded || state is OffersError || state is OfferActionSuccess) {
            _hideLoadingDialog(context);
            if (state is OffersError) {
              ToastHelper.showError(context, state.message);
            } else if (state is OfferActionSuccess) {
              ToastHelper.showSuccess(context, state.message);
            }
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(
              child: LoadingSpinner(),
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
                        backgroundColor: AppColors.primary,
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
        color: Colors.white,
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
                  'Solicitante: ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileDetailScreen(userId: offer.borrower.id),
                      ),
                    );
                  },
                  child: Text(
                    offer.borrower.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
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
            const SizedBox(height: 4),
            Text(
              'Solicitado: ${_formatCreatedDate(offer.request.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
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
                        const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'Punto de recogida:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
                        const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'Hora de recogida:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(otherUser: offer.borrower),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                if (offer.request.status == RentalRequestStatus.pending) ...[
                  ElevatedButton(
                    onPressed: () => _showApproveDialog(context, offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
        return AppColors.primary;
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

  String _formatCreatedDate(DateTime date) {
    return DateFormat('EEE d MMM yyyy', 'es').format(date);
  }

  void _showApproveDialog(BuildContext context, RentalRequestView offer) {
    // Obtener el bloc antes de abrir el dialog
    final bloc = context.read<OffersReceivedBloc>();
    final pickupLocationController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de recogida: ${_formatDate(offer.request.startDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acuerda el punto y hora de recogida:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D6D6D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pickupLocationController,
                      decoration: InputDecoration(
                        labelText: 'Punto de recogida',
                        hintText: 'Ej: Calle 123, Barrio Centro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        if (!dialogContext.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null && dialogContext.mounted) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedTime != null
                                    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Seleccionar hora',
                                style: TextStyle(
                                  color: selectedTime != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  onPressed: pickupLocationController.text.isNotEmpty &&
                          selectedTime != null
                      ? () {
                          Navigator.pop(ctx);
                          // Construir DateTime con la fecha de inicio + hora seleccionada
                          final pickupDateTime = DateTime(
                            offer.request.startDate.year,
                            offer.request.startDate.month,
                            offer.request.startDate.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );
                          // Usar el bloc obtenido antes del dialog
                          bloc.add(
                            ApproveOfferEvent(
                              offer.request.id!,
                              pickupLocationController.text,
                              pickupDateTime,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}