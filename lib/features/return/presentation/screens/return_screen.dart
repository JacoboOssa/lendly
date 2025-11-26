import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Pantalla de devolución de producto.
/// Permite al usuario devolver un producto alquilado con fecha, hora, notas y fotos.
class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();

  DateTime? _returnDate;
  TimeOfDay? _returnTime;
  String? _wouldRentAgain; // 'Si' o 'No'
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  // Dirección del propietario (NO editable, viene del alquiler aceptado)
  // TODO: Obtener esta dirección del alquiler real cuando se implemente
  final String _ownerAddress = 'Calle 123 #45-67, Cali, Colombia';

  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _returnDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _returnTime = picked);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null && picked.isNotEmpty) {
        setState(() => _images.addAll(picked));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron seleccionar imágenes')),
      );
    }
  }

  void _removeImageAt(int index) {
    setState(() => _images.removeAt(index));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de devolución')),
      );
      return;
    }
    if (_returnTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la hora de devolución')),
      );
      return;
    }
    if (_wouldRentAgain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indica si volverías a alquilar el producto'),
        ),
      );
      return;
    }

    // Simular envío exitoso
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _ReturnConfirmationScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F1F1F),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Devolucion del producto',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReturnFormField(
                  controller: _nameController,
                  label: 'Nombre y apellido',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                _DateTimeField(
                  label: 'Hora de devolucion',
                  date: _returnDate,
                  time: _returnTime,
                  onPickDate: _pickDate,
                  onPickTime: _pickTime,
                ),
                const SizedBox(height: 12),
                _ReadOnlyAddressField(address: _ownerAddress),
                const SizedBox(height: 12),
                _WouldRentAgainField(
                  value: _wouldRentAgain,
                  onChanged: (v) => setState(() => _wouldRentAgain = v),
                ),
                const SizedBox(height: 12),
                _ReturnFormField(
                  controller: _experienceController,
                  label: 'Experiencia con el producto (notas extra)...',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _PhotoUploadSection(
                  images: _images,
                  onPickImages: _pickImages,
                  onRemoveAt: _removeImageAt,
                ),
                const SizedBox(height: 32),
                _ReturnButton(onSubmit: _submit),
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

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const _DateTimeField({
    required this.label,
    required this.date,
    required this.time,
    required this.onPickDate,
    required this.onPickTime,
  });

  String _formatDate(DateTime? d) => d == null
      ? ''
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Seleccionar fecha'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickDate();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Seleccionar hora'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickTime();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
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
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF9E9E9E),
            ),
          ),
          controller: TextEditingController(
            text: date != null && time != null
                ? '${_formatDate(date)} ${_formatTime(time)}'
                : '',
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

class _WouldRentAgainField extends StatelessWidget {
  final String? value;
  final Function(String) onChanged;

  const _WouldRentAgainField({required this.value, required this.onChanged});

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
                child: Text(
                  'Volverias alquilar el producto (Si/No)',
                  style: TextStyle(
                    color: value == null
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF1F1F1F),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onChanged('Si'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: value == 'Si'
                        ? const Color(0xFF5B5670)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value == 'Si'
                          ? const Color(0xFF5B5670)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  child: Text(
                    'Si',
                    style: TextStyle(
                      color: value == 'Si'
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onChanged('No'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: value == 'No'
                        ? const Color(0xFF5B5670)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value == 'No'
                          ? const Color(0xFF5B5670)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: value == 'No'
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoUploadSection extends StatelessWidget {
  final List<XFile> images;
  final Future<void> Function() onPickImages;
  final void Function(int) onRemoveAt;

  const _PhotoUploadSection({
    required this.images,
    required this.onPickImages,
    required this.onRemoveAt,
  });

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
          ElevatedButton.icon(
            onPressed: onPickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text('Agregar más fotos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B5670),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
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
              ],
            ),
          ),
        );
      },
      child: Container(
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

class _ReturnButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const _ReturnButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B5670),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
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

class _ReturnConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F1F1F),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Devolucion del producto',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Petición devolución enviada al arrendador.',
                style: TextStyle(color: Color(0xFF1F1F1F), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navegar a la pantalla de productos alquilados cuando exista
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B5670),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver productos alquilados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
