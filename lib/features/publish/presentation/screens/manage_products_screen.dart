import 'package:flutter/material.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final List<_ProductItem> _products = [];

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
            color: Color(0xFF2C2C2C),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Productos listados',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para cargar datos demo (quitar cuando haya backend)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _loadDemoIfEmpty,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF98A1BC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cargar datos demo (quitar en prod)',
                    style: TextStyle(
                      color: Color(0xFF98A1BC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _products.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          return _ProductCard(
                            product: p,
                            onEdit: () => _editProduct(index),
                            onDelete: () => _deleteProduct(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadDemoIfEmpty() {
    if (_products.isNotEmpty) return;
    setState(() {
      // DEMO: productos mock. Reemplazar por fetch desde backend cuando exista.
      _products.addAll([
        _ProductItem(
          id: '1',
          name: 'Cámara Canon EOS',
          category: 'Tecnología',
          priceLabel: r'$60.000/día',
          imageUrl: null,
        ),
        _ProductItem(
          id: '2',
          name: 'Taladro Bosch',
          category: 'Herramientas',
          priceLabel: r'$45.000/día',
          imageUrl: null,
        ),
        _ProductItem(
          id: '3',
          name: 'Vestido de Gala',
          category: 'Ropa',
          priceLabel: r'$120.000/evento',
          imageUrl: null,
        ),
      ]);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _editProduct(int index) async {
    final item = _products[index];

    final updated = await showModalBottomSheet<_ProductItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _EditProductSheet(initial: item),
      ),
    );

    if (updated != null) {
      setState(() {
        _products[index] = updated;
      });
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 56, color: Color(0xFFBDBDBD)),
          SizedBox(height: 12),
          Text(
            'Aún no tienes productos listados',
            style: TextStyle(color: Color(0xFF6D6D6D)),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductItem product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl == null
                  ? const Center(
                      child: Icon(Icons.image, color: Color(0xFFBDBDBD)),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.priceLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B5670),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF98A1BC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Editar',
                            style: TextStyle(
                              color: Color(0xFF98A1BC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B5670),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProductSheet extends StatefulWidget {
  const _EditProductSheet({required this.initial});

  final _ProductItem initial;

  @override
  State<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<_EditProductSheet> {
  // Campos similares al formulario de publicación
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _priceUnit = '/Día';
  String? _category;
  String _condition = 'Nuevo';
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _featuresController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initial.name;
    _priceController.text = widget.initial.priceLabel.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    _category = widget.initial.category;
    // Los demás campos quedan vacíos para demo, ya que no existen en _ProductItem
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final priceLabel = '${_priceController.text.trim()}$_priceUnit';
    Navigator.pop(
      context,
      widget.initial.copyWith(
        name: _titleController.text.trim(),
        category: _category ?? widget.initial.category,
        priceLabel: priceLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Herramientas',
      'Electrónica',
      'Hogar',
      'Transporte',
      'Deportes',
      'Otro',
    ];
    if (_category != null && !categories.contains(_category)) {
      categories = [_category!, ...categories];
    }
    const conditions = ['Nuevo', 'Como nuevo', 'Usado', 'Con detalles'];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: SingleChildScrollView(
            controller: controller,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Editar producto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Título del objeto'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el título'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _category = v),
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
                            value: _condition,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: conditions
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _condition = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Descripción detallada'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _priceController,
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
                            value: _priceUnit,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: const ['/Hora', '/Día', '/Semana']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _priceUnit = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: _inputDecoration('País'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: _inputDecoration('Ciudad'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration(
                      'Dirección o punto de recogida',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _featuresController,
                    decoration: _inputDecoration('Características (opcional)'),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickStartDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: _inputDecoration(
                                'Disponibilidad desde',
                              ),
                              controller: TextEditingController(
                                text: _formatDate(_startDate),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickEndDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: _inputDecoration(
                                'Disponibilidad hasta',
                              ),
                              controller: TextEditingController(
                                text: _formatDate(_endDate),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98A1BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductItem {
  final String id;
  final String name;
  final String category;
  final String priceLabel; // ej: $60.000/día
  final String? imageUrl;

  _ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.priceLabel,
    required this.imageUrl,
  });

  _ProductItem copyWith({
    String? name,
    String? category,
    String? priceLabel,
    String? imageUrl,
  }) {
    return _ProductItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      priceLabel: priceLabel ?? this.priceLabel,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
