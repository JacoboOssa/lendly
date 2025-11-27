import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/return/presentation/bloc/return_bloc.dart';

/// Pantalla de devolución de producto.
/// Permite al usuario devolver un producto alquilado con fecha, hora, notas y fotos.
class ReturnScreen extends StatefulWidget {
  final Rental rental;
  final RentalRequest rentalRequest;
  final Product product;
  final AppUser owner;

  const ReturnScreen({
    super.key,
    required this.rental,
    required this.rentalRequest,
    required this.product,
    required this.owner,
  });

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? _returnTime;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReturnBloc(),
      child: _ReturnScreenContent(
        formKey: _formKey,
        returnTime: _returnTime,
        onTimePicked: (time) => setState(() => _returnTime = time),
        rental: widget.rental,
        rentalRequest: widget.rentalRequest,
        product: widget.product,
        owner: widget.owner,
      ),
    );
  }
}

class _ReturnScreenContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TimeOfDay? returnTime;
  final Function(TimeOfDay) onTimePicked;
  final Rental rental;
  final RentalRequest rentalRequest;
  final Product product;
  final AppUser owner;

  const _ReturnScreenContent({
    required this.formKey,
    required this.returnTime,
    required this.onTimePicked,
    required this.rental,
    required this.rentalRequest,
    required this.product,
    required this.owner,
  });

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) return;
    if (returnTime == null) {
      ToastHelper.showError(context, 'Selecciona la hora de devolución');
      return;
    }

    context.read<ReturnBloc>().add(
          CreateReturnEvent(
            rentalId: rental.id!,
            proposedReturnTime: returnTime!,
            note: null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReturnBloc, ReturnState>(
      listener: (context, state) {
        if (state is ReturnSuccess) {
          // Cerrar esta pantalla y navegar directamente a la calificación
          Navigator.of(context).pop(true); // Retornar true para indicar éxito
          // Navegar directamente a la pantalla de calificación
          Navigator.of(context).pushNamed(
            '/rating/owner_product',
            arguments: {
              'rentalId': rental.id!,
              'ownerUserId': owner.id,
              'ownerName': owner.name,
              'productId': product.id,
              'productTitle': product.title,
              'productPhotoUrl': product.photoUrl,
            },
          );
        } else if (state is ReturnError) {
          ToastHelper.showError(context, state.message);
        }
      },
      child: BlocBuilder<ReturnBloc, ReturnState>(
        builder: (context, state) {
          final isLoading = state is ReturnLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const CustomAppBar(
              title: 'Devolución del producto',
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ReadOnlyDateField(
                        date: rentalRequest.endDate,
                      ),
                      const SizedBox(height: 12),
                      _TimeField(
                        label: 'Hora de devolucion',
                        time: returnTime,
                        onTimePicked: onTimePicked,
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyAddressField(address: rental.pickupLocation),
                      const SizedBox(height: 32),
                      _ReturnButton(
                        onSubmit: () => _submit(context),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReadOnlyDateField extends StatelessWidget {
  final DateTime date;

  const _ReadOnlyDateField({required this.date});

  String _formatDate(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de devolución',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Fecha acordada en la solicitud (no editable)',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _TimeField extends StatefulWidget {
  final String label;
  final TimeOfDay? time;
  final Function(TimeOfDay) onTimePicked;

  const _TimeField({
    required this.label,
    required this.time,
    required this.onTimePicked,
  });

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  String _formatTime(TimeOfDay? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: widget.time ?? TimeOfDay.now(),
        );
        if (time != null) {
          widget.onTimePicked(time);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: const Icon(
              Icons.access_time,
              color: Color(0xFF9E9E9E),
            ),
          ),
          controller: TextEditingController(
            text: widget.time != null ? _formatTime(widget.time) : '',
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyAddressField extends StatelessWidget {
  final String address;

  const _ReadOnlyAddressField({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Localizacion',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Dirección del propietario (no editable)',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
          ),
        ),
      ],
    );
  }
}



class _ReturnButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _ReturnButton({
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Devolver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

