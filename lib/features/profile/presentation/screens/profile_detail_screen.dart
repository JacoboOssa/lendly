import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // Datos de prueba - En producción vendrían de un BLoC
  final String userName = "Marcelo Software";
  final String userEmail = "bimalstha291@gmail.com";
  final String userRole = "lender"; // "lender" o "borrower"
  final DateTime accountCreatedDate = DateTime(2023, 6, 15);
  final double rating = 4.5;
  final int totalTransactions = 24; // Productos alquilados (lender) o prestados (borrower)

  // Lista de reseñas de prueba
  final List<Review> reviews = [
    Review(
      authorName: "Juan Pérez",
      rating: 5.0,
      comment: "Excelente servicio, muy responsable con el cuidado del producto.",
      date: DateTime(2024, 11, 10),
    ),
    Review(
      authorName: "María González",
      rating: 4.0,
      comment: "Buen alquilador, solo hubo un pequeño retraso en la entrega.",
      date: DateTime(2024, 10, 25),
    ),
    Review(
      authorName: "Carlos Rodríguez",
      rating: 5.0,
      comment: "Perfecto estado del producto y entrega puntual. Muy recomendado.",
      date: DateTime(2024, 10, 15),
    ),
    Review(
      authorName: "Ana Martínez",
      rating: 4.5,
      comment: "Todo bien, el producto llegó en las condiciones descritas.",
      date: DateTime(2024, 9, 30),
    ),
  ];

  String _calculateAccountAge() {
    final now = DateTime.now();
    final difference = now.difference(accountCreatedDate);
    final months = (difference.inDays / 30).floor();
    final years = (months / 12).floor();

    if (years > 0) {
      return years == 1 ? "1 año" : "$years años";
    } else {
      return months == 1 ? "1 mes" : "$months meses";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _ProfileAvatar(userName: userName),
                      const SizedBox(height: 16),
                      _ProfileName(name: userName),
                      const SizedBox(height: 8),
                      _ProfileEmail(email: userEmail),
                      const SizedBox(height: 32),
                      _ProfileStatsCard(
                        accountAge: _calculateAccountAge(),
                        rating: rating,
                        totalTransactions: totalTransactions,
                        userRole: userRole,
                      ),
                      const SizedBox(height: 32),
                      _ReviewsSection(
                        reviews: reviews,
                        userRole: userRole,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Header con botón de regreso
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _ProfileHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
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
          const SizedBox(width: 12),
          const Text(
            'Detalle del Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Avatar del usuario
class _ProfileAvatar extends StatelessWidget {
  final String userName;

  const _ProfileAvatar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF9C88FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Widget: Nombre del usuario
class _ProfileName extends StatelessWidget {
  final String name;

  const _ProfileName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        color: Color(0xFF2C2C2C),
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// Widget: Email del usuario
class _ProfileEmail extends StatelessWidget {
  final String email;

  const _ProfileEmail({required this.email});

  @override
  Widget build(BuildContext context) {
    return Text(
      email,
      style: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 16,
      ),
    );
  }
}

// Widget: Tarjeta de estadísticas del perfil
class _ProfileStatsCard extends StatelessWidget {
  final String accountAge;
  final double rating;
  final int totalTransactions;
  final String userRole;

  const _ProfileStatsCard({
    required this.accountAge,
    required this.rating,
    required this.totalTransactions,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _StatItem(
            icon: Icons.calendar_today_outlined,
            label: 'Antigüedad',
            value: accountAge,
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          const SizedBox(height: 20),
          _StatItem(
            icon: Icons.star_rounded,
            label: 'Calificación',
            value: '$rating ⭐',
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          const SizedBox(height: 20),
          _StatItem(
            icon: Icons.shopping_bag_outlined,
            label: userRole == 'lender'
                ? 'Productos alquilados'
                : 'Productos prestados',
            value: totalTransactions.toString(),
          ),
        ],
      ),
    );
  }
}

// Widget: Item individual de estadística
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF555879).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF555879),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2C2C2C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget: Sección de reseñas
class _ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final String userRole;

  const _ReviewsSection({
    required this.reviews,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.rate_review_outlined,
              color: Color(0xFF555879),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              userRole == 'lender'
                  ? 'Reseñas realizadas'
                  : 'Reseñas de productos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        reviews.isEmpty
            ? _EmptyReviews()
            : _ReviewsList(reviews: reviews),
      ],
    );
  }
}

// Widget: Lista de reseñas vacía
class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reseñas aún',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Lista scrolleable de reseñas
class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _ReviewCard(review: reviews[index]);
        },
      ),
    );
  }
}

// Widget: Tarjeta individual de reseña
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF555879),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.authorName.isNotEmpty
                        ? review.authorName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _RatingStars(rating: review.rating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6D6D6D),
                height: 1.5,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDate(review.date),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Estrellas de calificación
class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star_rounded,
            size: 16,
            color: Color(0xFFFFB800),
          );
        } else if (index < rating) {
          return const Icon(
            Icons.star_half_rounded,
            size: 16,
            color: Color(0xFFFFB800),
          );
        } else {
          return const Icon(
            Icons.star_outline_rounded,
            size: 16,
            color: Color(0xFFE0E0E0),
          );
        }
      }),
    );
  }
}

// Modelo de datos para reseñas
class Review {
  final String authorName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
