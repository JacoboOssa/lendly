import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/core/widgets/skeleton_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/publish/presentation/bloc/manage_products_bloc.dart';
import 'package:lendly_app/main.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String? _lastOperation; // 'update', 'delete', 'toggle'
  bool _wasProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      context.read<ManageProductsBloc>().add(LoadUserProducts(currentUser.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Productos listados',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: BlocConsumer<ManageProductsBloc, ManageProductsState>(
            listener: (context, state) {
              if (state is ManageProductsError) {
                ToastHelper.showError(context, state.message);
                _lastOperation = null;
                _wasProcessing = false;
              } else if (state is ManageProductsLoaded) {
                // Detectar cuando se completa una operación
                if (_wasProcessing && !state.isProcessing && _lastOperation != null) {
                  switch (_lastOperation) {
                    case 'update':
                      ToastHelper.showSuccess(context, 'Producto actualizado exitosamente');
                      break;
                    case 'delete':
                      ToastHelper.showSuccess(context, 'Producto eliminado exitosamente');
                      break;
                    case 'toggle':
                      ToastHelper.showSuccess(context, 'Disponibilidad actualizada exitosamente');
                      break;
                  }
                  _lastOperation = null;
                }
                _wasProcessing = state.isProcessing;
              }
            },
            builder: (context, state) {
              // Spinner en carga inicial
              if (state is ManageProductsLoading && state.isInitialLoad) {
                return const Center(
                  child: LoadingSpinner(),
                );
              }

              if (state is ManageProductsLoaded) {
                if (state.products.isEmpty) {
                  return const _EmptyState();
                }
                return Stack(
                  children: [
                    _ProductsList(
                      products: state.products,
                      onEdit: _editProduct,
                      onDelete: _deleteProduct,
                      onToggleAvailability: _toggleAvailability,
                    ),
                    // Spinner durante operaciones (actualizar, eliminar, toggle)
                    if (state.isProcessing)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: LoadingSpinner(),
                        ),
                      ),
                  ],
                );
              }

              return const _EmptyState();
            },
          ),
        ),
      ),
    );
  }

  void _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de eliminar "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && product.id != null) {
      _lastOperation = 'delete';
      _wasProcessing = true;
      context.read<ManageProductsBloc>().add(DeleteProduct(product.id!));
    }
  }

  void _editProduct(Product product) async {
    final updated = await showModalBottomSheet<Product>(
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
        child: _EditProductSheet(product: product),
      ),
    );

    if (updated != null) {
      _lastOperation = 'update';
      _wasProcessing = true;
      context.read<ManageProductsBloc>().add(UpdateProduct(updated));
    }
  }

  void _toggleAvailability(Product product) {
    _lastOperation = 'toggle';
    _wasProcessing = true;
    context.read<ManageProductsBloc>().add(ToggleProductAvailability(product));
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

class _ProductsList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(Product) onDelete;
  final Function(Product) onToggleAvailability;

  const _ProductsList({
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          onEdit: () => onEdit(product),
          onDelete: () => onDelete(product),
          onToggleAvailability: () => onToggleAvailability(product),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  String _formatPrice(int priceInCents) {
    final price = priceInCents / 100;
    return '\$${price.toStringAsFixed(0)}/día';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: product.photoUrl == null
                  ? const Center(
                      child: Icon(Icons.image, color: Color(0xFFBDBDBD)),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            // Imagen cargada completamente
                            return child;
                          }
                          // Mostrar skeleton mientras carga
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey[400]!,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: product.isAvailable
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.isAvailable
                                    ? 'Disponible'
                                    : 'No disponible',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: product.isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: product.isAvailable,
                          onChanged: (_) => onToggleAvailability(),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: const Color(0xFFC8E6C9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category ?? 'Sin categoría',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(product.pricePerDayCents),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Editar',
                            style: TextStyle(
                              color: AppColors.primary,
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
                            backgroundColor: AppColors.primary,
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
  const _EditProductSheet({required this.product});

  final Product product;

  @override
  State<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<_EditProductSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;
  String _condition = 'Nuevo';
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _pickupNotesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _descriptionController.text = widget.product.description ?? '';
    _priceController.text = (widget.product.pricePerDayCents / 100).toString();
    _category = widget.product.category;
    _condition = widget.product.condition ?? 'Nuevo';
    _countryController.text = widget.product.country ?? '';
    _cityController.text = widget.product.city ?? '';
    _addressController.text = widget.product.address ?? '';
    _pickupNotesController.text = widget.product.pickupNotes ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _pickupNotesController.dispose();
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final priceText = _priceController.text.trim();
    final priceValue = double.tryParse(priceText) ?? 0;
    final priceInCents = (priceValue * 100).toInt();

    final updatedProduct = Product(
      id: widget.product.id,
      ownerId: widget.product.ownerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category ?? widget.product.category,
      pricePerDayCents: priceInCents,
      condition: _condition,
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      pickupNotes: _pickupNotesController.text.trim(),
      photoUrl: widget.product.photoUrl,
      active: widget.product.active,
      isAvailable: widget.product.isAvailable,
      ratingAvg: widget.product.ratingAvg,
      createdAt: widget.product.createdAt,
    );

    Navigator.pop(context, updatedProduct);
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
                            initialValue: _category,
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
                            initialValue: _condition,
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
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Precio por día'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el precio'
                        : null,
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
                    controller: _pickupNotesController,
                    decoration: _inputDecoration(
                      'Notas de recogida (opcional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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

