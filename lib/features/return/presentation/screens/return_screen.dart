import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/return/domain/usecases/create_return_usecase.dart';
import 'package:intl/intl.dart';

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
  final _experienceController = TextEditingController();

  TimeOfDay? _returnTime;
  final CreateReturnUseCase _createReturnUseCase = CreateReturnUseCase();
  bool _isLoading = false;

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_returnTime == null) {
      ToastHelper.showError(context, 'Selecciona la hora de devolución');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _createReturnUseCase.execute(
        rentalId: widget.rental.id!,
        proposedReturnTime: _returnTime!,
        note: _experienceController.text.trim().isEmpty
            ? null
            : _experienceController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Cerrar esta pantalla y navegar directamente a la calificación
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
        // Navegar directamente a la pantalla de calificación
        Navigator.of(context).pushNamed(
          '/rating/owner_product',
          arguments: {
            'rentalId': widget.rental.id!,
            'ownerUserId': widget.owner.id,
            'ownerName': widget.owner.name,
            'productId': widget.product.id,
            'productTitle': widget.product.title,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastHelper.showError(context, 'Error al procesar la devolución: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Devolución del producto',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReadOnlyDateField(
                  date: widget.rentalRequest.endDate,
                ),
                const SizedBox(height: 12),
                _TimeField(
                  label: 'Hora de devolucion',
                  time: _returnTime,
                  onTimePicked: (time) => setState(() => _returnTime = time),
                ),
                const SizedBox(height: 12),
                _ReadOnlyAddressField(address: widget.rental.pickupLocation),
                const SizedBox(height: 12),
                _ReturnFormField(
                  controller: _experienceController,
                  label: 'Experiencia con el producto (notas extra)...',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                _ReturnButton(
                  onSubmit: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturnFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ReturnFormField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
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
  final Future<void> Function() onSubmit;
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

