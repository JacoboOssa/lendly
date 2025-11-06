import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botones de navegación
              const _HeaderButtons(),
              
              // Galería de imágenes del producto
              const _ProductImageGallery(),
              
              // Información principal del producto
              const _ProductMainInfo(),
              
              // Selector de talla
              const _SizeSelector(),
              
              // Selector de color
              const _ColorSelector(),
              
              // Descripción del producto
              const _ProductDescription(),
              
              // Envío y devoluciones
              const _ShippingInfo(),
              
              // Información del propietario
              const _OwnerInfo(),
              
              // Reseñas
              const _ReviewsSection(),
              
              // Botones de acción (precio y añadir al carrito)
              const _ActionButtons(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget: Botones del header (atrás y favorito)
class _HeaderButtons extends StatelessWidget {
  const _HeaderButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón atrás
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          // Botón favorito
          GestureDetector(
            onTap: () {
              // TODO: Implementar lógica de favoritos
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 20,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Galería de imágenes del producto
class _ProductImageGallery extends StatefulWidget {
  const _ProductImageGallery();

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  int _currentImageIndex = 0;
  
  // Imagen por defecto (URL de placeholder)
  final String _defaultImage = 'https://via.placeholder.com/400x300/98A1BC/FFFFFF?text=Producto';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen principal
        Container(
          height: 300,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _defaultImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Color(0xFF555879),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
              return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == index
                    ? const Color(0xFF555879)
                    : const Color(0xFFE0E0E0),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Widget: Información principal del producto (título y precio)
class _ProductMainInfo extends StatelessWidget {
  const _ProductMainInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chaqueta Adidas x El pato Donald',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$148.000/mes',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Información de talla
class _SizeSelector extends StatelessWidget {
  const _SizeSelector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Talla',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF555879),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Información de color
class _ColorSelector extends StatelessWidget {
  const _ColorSelector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB5C99A),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2C2C2C),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Descripción del producto
class _ProductDescription extends StatelessWidget {
  const _ProductDescription();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diseñada para la vida y hecha para durar, esta chaqueta de pana con cierre completo forma parte de nuestra colección Nike Life. Su corte amplio es el espacio suficiente para agregar capas y la manga que se suelte mantiene en estilo casual y atemporal.',
            style: TextStyle(
              color: Color(0xFF6D6D6D),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Información de envío
class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Envío y devoluciones',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Envío estándar gratis',
            style: TextStyle(
              color: Color(0xFF6D6D6D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Información del propietario
class _OwnerInfo extends StatelessWidget {
  const _OwnerInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Propietario',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatar del propietario
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF555879),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Nombre del propietario
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Morgan',
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Botones de contacto
              _ContactButton(
                icon: Icons.phone,
                onTap: () {
                  // TODO: Implementar llamada
                },
              ),
              const SizedBox(width: 8),
              _ContactButton(
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  // TODO: Implementar chat
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget: Botón de contacto
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF555879),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// Widget: Sección de reseñas
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reseñas',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Calificación promedio
          const Row(
            children: [
              Text(
                'Calificación de',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '4.5',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '213 Reviews',
            style: TextStyle(
              color: Color(0xFF6D6D6D),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Reseña individual
          const _ReviewItem(
            userName: 'Dana White',
            rating: 4,
            comment: 'La calzada estaba en perfecto estado, limpia. Muy cómoda.',
            daysAgo: 2,
          ),
        ],
      ),
    );
  }
}

// Widget: Item de reseña individual
class _ReviewItem extends StatelessWidget {
  final String userName;
  final int rating;
  final String comment;
  final int daysAgo;

  const _ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.daysAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar del usuario
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF555879),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y estrellas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Estrellas
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comentario
          Text(
            comment,
            style: const TextStyle(
              color: Color(0xFF6D6D6D),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Tiempo
          Text(
            'Hace $daysAgo días',
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Botón de acción (añadir al carrito con precio)
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: Implementar añadir al carrito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto añadido al carrito'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF555879),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '\$148.000/mes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40),
              const Text(
                'Añadir al carrito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
