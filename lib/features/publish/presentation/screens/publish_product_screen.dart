import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';
import 'package:lendly_app/features/publish/presentation/bloc/create_product_bloc.dart';
import 'package:lendly_app/main.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/utils/app_colors.dart';

/// Pantalla para publicar un producto/objeto.
/// Código separado en widgets pequeños: _Header, _ProductForm, _PhotoUploader, _FooterActions
class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends State<PublishProductScreen> {
  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _featuresController = TextEditingController();
  final _descriptionController = TextEditingController();

  // state
  String? _category;
  String _condition = 'Nuevo';
  String _priceUnit = '/Hora';
  bool _termsAccepted = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  DateTime? _startDate;
  DateTime? _endDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _featuresController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null && picked.isNotEmpty) {
        setState(() => _images.addAll(picked));
      }
    } catch (e) {
      ToastHelper.showError(context, 'No se pudieron seleccionar imágenes');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (photo != null) setState(() => _images.add(photo));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      );
      ToastHelper.showError(context, 'No se pudo tomar la foto');
    }
  }

  void _removeImageAt(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ToastHelper.showError(context, 'Debes aceptar términos y condiciones');
      return;
    }

    if (_startDate == null || _endDate == null) {
      ToastHelper.showError(context, 'Debes seleccionar fechas de disponibilidad');
      return;
    }

    try {
      // Obtener el usuario actual
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        );
        ToastHelper.showError(context, 'Debes iniciar sesión');
        return;
      }

      // Convertir precio a centavos
      final priceText = _priceController.text.trim();
      final priceValue = double.tryParse(priceText) ?? 0;
      final priceInCents = (priceValue * 100).toInt();

      // Obtener bytes de la primera imagen si existe
      Uint8List? imageBytes;
      if (_images.isNotEmpty) {
        final file = File(_images.first.path);
        imageBytes = await file.readAsBytes();
      }

      // Crear el producto
      final product = Product(
        ownerId: currentUser.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        pricePerDayCents: priceInCents,
        condition: _condition,
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        pickupNotes: _featuresController.text.trim(),
      );

      // Crear disponibilidad
      final availability = Availability(
        itemId: '', // Se asignará después de crear el producto
        startDate: _startDate!,
        endDate: _endDate!,
        isBlocked: false,
      );

      // Enviar evento al BLoC
      context.read<CreateProductBloc>().add(
        CreateProductSubmitted(
          product: product,
          availabilities: [availability],
          photoBytes: imageBytes,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      );
      ToastHelper.showError(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProductBloc, CreateProductState>(
      listener: (context, state) {
        if (state is CreateProductLoading) {
          LoadingDialog.show(context, message: 'Publicando producto...');
        } else if (state is CreateProductSuccess) {
          LoadingDialog.hide(context);
          ToastHelper.showSuccess(context, '¡Producto publicado exitosamente!');
          Navigator.of(context).pop();
        } else if (state is CreateProductError) {
          LoadingDialog.hide(context);
          ToastHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
            child: Column(
              children: [
                const _Header(),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),
                          _ProductForm(
                            titleController: _titleController,
                            priceController: _priceController,
                            priceUnit: _priceUnit,
                            onUnitChanged: (v) =>
                                setState(() => _priceUnit = v),
                            countryController: _countryController,
                            cityController: _cityController,
                            addressController: _addressController,
                            featuresController: _featuresController,
                            descriptionController: _descriptionController,
                            category: _category,
                            onCategoryChanged: (v) =>
                                setState(() => _category = v),
                            condition: _condition,
                            onConditionChanged: (v) =>
                                setState(() => _condition = v),
                            startDate: _startDate,
                            endDate: _endDate,
                            onPickStartDate: _pickStartDate,
                            onPickEndDate: _pickEndDate,
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              'Fotos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _PhotoUploader(
                            images: _images,
                            onPickImages: _pickImages,
                            onTakePhoto: _takePhoto,
                            onRemoveAt: _removeImageAt,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Checkbox(
                                value: _termsAccepted,
                                onChanged: (v) =>
                                    setState(() => _termsAccepted = v ?? false),
                              ),
                              const Expanded(
                                child: Text('Terminos y condiciones'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _FooterActions(onSubmit: _submit),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Añadir producto',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    super.key,
    required this.titleController,
    required this.priceController,
    required this.priceUnit,
    required this.onUnitChanged,
    required this.countryController,
    required this.cityController,
    required this.addressController,
    required this.featuresController,
    required this.descriptionController,
    required this.category,
    required this.onCategoryChanged,
    required this.condition,
    required this.onConditionChanged,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
  });

  final TextEditingController titleController;
  final TextEditingController priceController;
  final String priceUnit;
  final ValueChanged<String> onUnitChanged;
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController featuresController;
  final TextEditingController descriptionController;
  final String? category;
  final ValueChanged<String?> onCategoryChanged;
  final String condition;
  final ValueChanged<String> onConditionChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;

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

  String _formatDate(DateTime? d) => d == null
      ? ''
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Herramientas',
      'Electrónica',
      'Hogar',
      'Transporte',
      'Deportes',
      'Otro',
    ];
    const conditions = ['Nuevo', 'Como nuevo', 'Usado', 'Con detalles'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: titleController,
          decoration: _inputDecoration('Título del objeto'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el título' : null,
        ),
        const SizedBox(height: 12),

        // Category + Condition row
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: onCategoryChanged,
                  hint: const Text('Categoría'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: condition,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: conditions
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onConditionChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: _inputDecoration('Descripción detallada'),
          maxLines: 4,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Ingresa una descripción'
              : null,
        ),
        const SizedBox(height: 12),

        // Price + unit
        Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Precio'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el precio'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: priceUnit,
                  isDense: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: const ['/Hora', '/Día', '/Semana']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onUnitChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Country / City / Address
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: countryController,
                decoration: _inputDecoration('País'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cityController,
                decoration: _inputDecoration('Ciudad'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          decoration: _inputDecoration('Dirección o punto de recogida'),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: featuresController,
          decoration: _inputDecoration('Características (opcional)'),
          maxLines: 2,
        ),
        const SizedBox(height: 12),

        // Availability dates
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onPickStartDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration('Disponibilidad desde'),
                    controller: TextEditingController(
                      text: _formatDate(startDate),
                    ),
                    validator: (v) =>
                        (startDate == null) ? 'Selecciona fecha inicio' : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onPickEndDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration('Disponibilidad hasta'),
                    controller: TextEditingController(
                      text: _formatDate(endDate),
                    ),
                    validator: (v) =>
                        (endDate == null) ? 'Selecciona fecha fin' : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoUploader extends StatelessWidget {
  const _PhotoUploader({
    super.key,
    required this.images,
    required this.onPickImages,
    required this.onTakePhoto,
    required this.onRemoveAt,
  });

  final List<XFile> images;
  final Future<void> Function() onPickImages;
  final Future<void> Function() onTakePhoto;
  final void Function(int) onRemoveAt;

  @override
  Widget build(BuildContext context) {
    if (images.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (c, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(images[i].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => onRemoveAt(i),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: images.length,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Agregar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar'),
              ),
            ],
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
        // show options
        showModalBottomSheet(
          context: context,
          builder: (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar fotos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onPickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onTakePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: DottedBorderContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.upload_file, size: 28, color: Color(0xFF9E9E9E)),
            SizedBox(height: 8),
            Text(
              'Subir fotos del objeto',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  const _FooterActions({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onSubmit,
        child: const Text(
          'Subir',
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

/// Simple visual container with dashed border used as upload area.
class DottedBorderContainer extends StatelessWidget {
  const DottedBorderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(child: child),
    );
  }
}
