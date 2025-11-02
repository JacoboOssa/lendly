import 'package:flutter/material.dart';


  @override
  State<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  final Map<String, bool> _availability = {};

  final List<_UiProduct> _demoProducts = const [
    _UiProduct(id: 'p1', name: 'Cámara DSLR Canon', isAvailable: true),
    _UiProduct(id: 'p2', name: 'Taladro percutor Bosch', isAvailable: false),
    _UiProduct(id: 'p3', name: 'Proyector portátil', isAvailable: true),
  ];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManageAvailabilityArgs) {
      _availability[args.productId] = args.isAvailable;
    } else {
      for (final p in _demoProducts) {
        _availability[p.id] = p.isAvailable;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isSingle = args is ManageAvailabilityArgs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C2C2C), size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Gestionar disponibilidad',
          style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Controla cuándo tus productos pueden ser alquilados. '
                    'Si un producto está "No disponible", no aparecerá en las búsquedas.',
                    style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                if (isSingle) _buildSingleProductSection(args as ManageAvailabilityArgs) else _buildListSection(),

                const SizedBox(height: 24),
                _buildActions(isSingle: isSingle, args: isSingle ? args as ManageAvailabilityArgs : null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleProductSection(ManageAvailabilityArgs args) {
    final available = _availability[args.productId] ?? args.isAvailable;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _ProductAvatar(imageUrl: args.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    args.name,
                    style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  _StatusChip(isAvailable: available),
                ],
              ),
            ),
            Switch(
              value: available,
              activeColor: const Color(0xFF98A1BC),
              onChanged: (v) => setState(() => _availability[args.productId] = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection() {
    return Column(
      children: _demoProducts.map((p) => _ProductTile(
        product: p,
        value: _availability[p.id] ?? p.isAvailable,
        onChanged: (v) => setState(() => _availability[p.id] = v),
      )).toList(),
    );
  }

  Widget _buildActions({required bool isSingle, ManageAvailabilityArgs? args}) {
    final changesCount = isSingle
        ? 1
        : _demoProducts
            .where((p) => _availability[p.id] != p.isAvailable)
            .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF98A1BC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: changesCount == 0 ? null : () => _onSave(isSingle: isSingle, args: args),
            child: Text(
              isSingle
                  ? 'Guardar cambios'
                  : (changesCount > 0 ? 'Guardar ($changesCount cambio${changesCount == 1 ? '' : 's'})' : 'Guardar'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF98A1BC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF98A1BC), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _onSave({required bool isSingle, ManageAvailabilityArgs? args}) {
    // TODO: Conectar con BLoC/UseCase para persistir cambios en backend.
    // Para integración: enviar productId(s) y estado(s) deseado(s) en _availability.

    // UX: Mostrar feedback local y volver
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponibilidad actualizada')),
    );
    Navigator.of(context).maybePop(_availability);
  }
}

class ManageAvailabilityArgs {
  final String productId;
  final String name;
  final bool isAvailable;
  final String? imageUrl;

  const ManageAvailabilityArgs({
    required this.productId,
    required this.name,
    required this.isAvailable,
    this.imageUrl,
  });
}

class _ProductTile extends StatelessWidget {
  final _UiProduct product;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProductTile({required this.product, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const _ProductAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  _StatusChip(isAvailable: value),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: const Color(0xFF98A1BC),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isAvailable;
  const _StatusChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? const Color(0xFF98A1BC) : Colors.grey.shade300).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'Disponible' : 'No disponible',
        style: TextStyle(
          color: isAvailable ? const Color(0xFF98A1BC) : const Color(0xFF6D6D6D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  final String? imageUrl;
  const _ProductAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl == null
          ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF98A1BC))
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl!, fit: BoxFit.cover),
            ),
    );
  }
}

class _UiProduct {
  final String id;
  final String name;
  final bool isAvailable;
  const _UiProduct({required this.id, required this.name, required this.isAvailable});
}
