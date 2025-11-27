import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/domain/model/payment.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/checkout/domain/repositories/payment_repository.dart';
import 'package:intl/intl.dart';

/// Pantalla de Checkout con datos reales del payment.
/// Permite capturar dirección de envío y método de pago antes de finalizar.
class CheckoutScreen extends StatefulWidget {
  final Payment payment;

  const CheckoutScreen({
    super.key,
    required this.payment,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _hasAddress = false;
  bool _hasPayment = false;
  String _savedAddress = '';
  String _savedCardLast4 = '';
  bool _isProcessing = false;
  final PaymentRepository _paymentRepository = PaymentRepositoryImpl(PaymentDataSourceImpl());

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    return formatter.format(amount);
  }

  double get _subtotal => widget.payment.totalAmount;
  double get _tax => 0.0; // Impuesto (puede ser calculado si es necesario)
  double get _total => _subtotal + _tax;

  Future<void> _processPayment() async {
    if (!_hasAddress || !_hasPayment) {
      ToastHelper.showError(context, 'Por favor completa la dirección y el método de pago');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _paymentRepository.updatePaymentStatus(widget.payment.id!, true);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Retornar true para indicar que se pagó
        ToastHelper.showSuccess(context, 'Pago realizado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error al procesar el pago: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _hasAddress && _hasPayment ? 'Finalizar compra' : 'Pagar',
        onBackPressed: () => Navigator.of(context).maybePop(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CheckoutCard(
                      label: 'Dirección de envío',
                      subtitle: _hasAddress
                          ? _savedAddress
                          : 'Añadir Dirección de envío',
                      filled: _hasAddress,
                      onTap: () => _showAddressSheet(),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutCard(
                      label: 'Método de pago',
                      subtitle: _hasPayment
                          ? '**** $_savedCardLast4'
                          : 'Añadir Método de pago',
                      filled: _hasPayment,
                      trailing: _hasPayment
                          ? const _CardBrandBadge(
                              brandAssetColor: Color(0xFFFFAF02),
                              brandSecondaryColor: Color(0xFFEC1C24),
                            )
                          : null,
                      onTap: () => _showPaymentSheet(),
                    ),
                    const SizedBox(height: 32),
                    _SummarySection(
                      subtotal: _subtotal,
                      tax: _tax,
                      total: _total,
                      formatCurrency: _formatCurrency,
                    ),
                  ],
                ),
              ),
            ),
            _CheckoutFooter(
              totalLabel: _formatCurrency(_total),
              buttonLabel: _isProcessing ? 'Procesando...' : 'Realizar el pago',
              onSubmit: _isProcessing ? null : _processPayment,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSheet() {
    final addressController = TextEditingController(text: _savedAddress);
    final cityController = TextEditingController();
    final countryController = TextEditingController();
    final postalCodeController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddressFormSheet(
          addressController: addressController,
          cityController: cityController,
          countryController: countryController,
          postalCodeController: postalCodeController,
          onSave: (address) {
            Navigator.pop(context);
            setState(() {
              _savedAddress = address;
              _hasAddress = true;
            });
          },
        ),
      ),
    );
  }

  void _showPaymentSheet() {
    final cardNumberController = TextEditingController();
    final cardNameController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _PaymentFormSheet(
          cardNumberController: cardNumberController,
          cardNameController: cardNameController,
          expiryController: expiryController,
          cvvController: cvvController,
          onSave: (last4) {
            Navigator.pop(context);
            setState(() {
              _savedCardLast4 = last4;
              _hasPayment = true;
            });
          },
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool filled;
  final Widget? trailing;
  final VoidCallback onTap;

  const _CheckoutCard({
    required this.label,
    required this.subtitle,
    required this.filled,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: filled
                          ? AppColors.textPrimary
                          : const Color(0xFF9E9E9E),
                      fontSize: 16,
                      fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            Icon(
              Icons.chevron_right,
              color: filled ? AppColors.primary : const Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final String Function(double) formatCurrency;

  const _SummarySection({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final entries = [
      _SummaryEntry(label: 'Subtotal', value: formatCurrency(subtotal)),
      _SummaryEntry(label: 'Impuesto', value: formatCurrency(tax)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _SummaryRow(entry: e),
          ),
        ),
        const SizedBox(height: 12),
        _SummaryRow(
          entry: _SummaryEntry(
            label: 'Total',
            value: formatCurrency(total),
            highlight: true,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final _SummaryEntry entry;
  const _SummaryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          entry.label,
          style: TextStyle(
            color: entry.highlight
                ? const Color(0xFF1F1F1F)
                : const Color(0xFF807B7A),
            fontWeight: entry.highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          entry.value,
          style: TextStyle(
            color: entry.highlight
                ? const Color(0xFF1F1F1F)
                : const Color(0xFF807B7A),
            fontWeight: entry.highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SummaryEntry {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryEntry({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class _CheckoutFooter extends StatelessWidget {
  final String totalLabel;
  final String buttonLabel;
  final VoidCallback? onSubmit;

  const _CheckoutFooter({
    required this.totalLabel,
    required this.buttonLabel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                totalLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBrandBadge extends StatelessWidget {
  final Color brandAssetColor;
  final Color brandSecondaryColor;

  const _CardBrandBadge({
    required this.brandAssetColor,
    required this.brandSecondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: brandAssetColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: brandSecondaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController postalCodeController;
  final Function(String) onSave;

  const _AddressFormSheet({
    required this.addressController,
    required this.cityController,
    required this.countryController,
    required this.postalCodeController,
    required this.onSave,
  });

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  void _save() {
    if (_formKey.currentState!.validate()) {
      final address =
          '${widget.addressController.text.trim()}, ${widget.cityController.text.trim()}, ${widget.countryController.text.trim()}';
      widget.onSave(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dirección de envío',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: widget.addressController,
                      decoration: _inputDecoration('Dirección'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa la dirección'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.cityController,
                            decoration: _inputDecoration('Ciudad'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa la ciudad'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: widget.postalCodeController,
                            decoration: _inputDecoration('Código postal'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: widget.countryController,
                      decoration: _inputDecoration('País'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el país'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar dirección',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentFormSheet extends StatefulWidget {
  final TextEditingController cardNumberController;
  final TextEditingController cardNameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final Function(String) onSave;

  const _PaymentFormSheet({
    required this.cardNumberController,
    required this.cardNameController,
    required this.expiryController,
    required this.cvvController,
    required this.onSave,
  });

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  String _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    final chunks = <String>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      chunks.add(
        cleaned.substring(i, i + 4 > cleaned.length ? cleaned.length : i + 4),
      );
    }
    return chunks.join(' ');
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final cardNumber = widget.cardNumberController.text.replaceAll(' ', '');
      final last4 = cardNumber.length >= 4
          ? cardNumber.substring(cardNumber.length - 4)
          : '';
      widget.onSave(last4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Método de pago',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: widget.cardNumberController,
                      decoration: _inputDecoration('Número de tarjeta'),
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      onChanged: (value) {
                        final formatted = _formatCardNumber(value);
                        if (formatted != value) {
                          widget.cardNumberController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                      },
                      validator: (v) {
                        final cleaned = v?.replaceAll(' ', '') ?? '';
                        if (cleaned.isEmpty)
                          return 'Ingresa el número de tarjeta';
                        if (cleaned.length < 13 || cleaned.length > 19) {
                          return 'Número de tarjeta inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: widget.cardNameController,
                      decoration: _inputDecoration('Nombre en la tarjeta'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el nombre'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.expiryController,
                            decoration: _inputDecoration('MM/AA'),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            onChanged: (value) {
                              if (value.length == 2 && !value.contains('/')) {
                                widget.expiryController.value = TextEditingValue(
                                  text: '$value/',
                                  selection: TextSelection.collapsed(offset: 3),
                                );
                              }
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Ingresa la fecha';
                              if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                                return 'Formato inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: widget.cvvController,
                            decoration: _inputDecoration('CVV'),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ingresa el CVV';
                              if (v.length < 3) return 'CVV inválido';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar método',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
