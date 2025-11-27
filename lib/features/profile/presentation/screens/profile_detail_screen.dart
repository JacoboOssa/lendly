import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/features/profile/presentation/bloc/profile_detail_bloc.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileDetailBloc()..add(LoadProfileDetail(userId)),
      child: const _ProfileDetailView(),
    );
  }
}

class _ProfileDetailView extends StatelessWidget {
  const _ProfileDetailView();

  String _calculateAccountAge(DateTime? accountCreatedDate) {
    if (accountCreatedDate == null) {
      return 'N/A';
    }
    final now = DateTime.now();
    final difference = now.difference(accountCreatedDate);
    final days = difference.inDays;
    final months = (days / 30).floor();
    final years = (months / 12).floor();

    if (years > 0) {
      return years == 1 ? "1 año" : "$years años";
    } else if (months > 0) {
      return months == 1 ? "1 mes" : "$months meses";
    } else {
      // Menos de un mes
      return "<1 mes";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
          builder: (context, state) {
            if (state is ProfileDetailLoading) {
              return const Center(
                child: LoadingSpinner(),
              );
            }

            if (state is ProfileDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ProfileDetailLoaded) {
              return Column(
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
                            _ProfileAvatar(userName: state.user.name),
                            const SizedBox(height: 16),
                            _ProfileName(name: state.user.name),
                            const SizedBox(height: 8),
                            _ProfileEmail(email: state.user.email),
                            const SizedBox(height: 32),
                            _ProfileStatsCard(
                              accountAge: _calculateAccountAge(state.accountCreatedDate),
                              totalTransactions: state.transactionsCount,
                              userRole: state.user.role,
                            ),
                            const SizedBox(height: 32),
                            if (state.averageRating != null) ...[
                              _RatingSection(
                                averageRating: state.averageRating!,
                                ratings: state.ratings,
                                hasMoreRatings: state.hasMoreRatings,
                                isLoadingMore: state.isLoadingMoreRatings,
                                onLoadMore: () {
                                  context.read<ProfileDetailBloc>().add(LoadMoreRatings());
                                },
                              ),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
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
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: onBackPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
  final int totalTransactions;
  final String userRole;

  const _ProfileStatsCard({
    required this.accountAge,
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
            icon: Icons.shopping_bag_outlined,
            label: userRole.toLowerCase() == 'lender'
                ? 'Productos prestados'
                : 'Productos alquilados',
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

// Widget: Sección de calificaciones y reseñas
class _RatingSection extends StatelessWidget {
  final double averageRating;
  final List<dynamic> ratings;
  final bool hasMoreRatings;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const _RatingSection({
    required this.averageRating,
    required this.ratings,
    required this.hasMoreRatings,
    required this.isLoadingMore,
    required this.onLoadMore,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Calificación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (ratings.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Reseñas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return _ReviewCard(rating: rating);
              },
            ),
            if (hasMoreRatings) ...[
              const SizedBox(height: 16),
              Center(
                child: isLoadingMore
                    ? const LoadingSpinner()
                    : TextButton(
                        onPressed: onLoadMore,
                        child: const Text(
                          'Cargar más reseñas',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'Aún no hay reseñas',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget: Tarjeta de reseña individual
class _ReviewCard extends StatelessWidget {
  final dynamic rating;

  const _ReviewCard({required this.rating});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStars(rating.rating),
              const Spacer(),
              Text(
                _formatDate(rating.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rating.comment!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C2C2C),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

