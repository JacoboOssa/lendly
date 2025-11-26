import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/widgets/skeleton_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/home/presentation/bloc/available_products_bloc.dart';
import 'package:lendly_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:lendly_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:lendly_app/features/product/presentation/bloc/rental_request_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AvailableProductsBloc>().add(
      LoadAvailableProducts(isInitialLoad: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AvailableProductsBloc, AvailableProductsState>(
        builder: (context, state) {
          if (state is AvailableProductsInitialLoading ||
              state is AvailableProductsIdle) {
            return const FullPageSkeletonLoader();
          }

          if (state is AvailableProductsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is AvailableProductsLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(),
                    const SizedBox(height: 20),
                    _SearchBar(),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    _SectionTitle(title: 'Categorías', actionText: 'Ver todo'),
                    const SizedBox(height: 12),
                    _CategoriesRow(),
                    const SizedBox(height: 12),
                    _SectionTitle(
                      title: 'Productos disponibles',
                      actionText: 'Ver todo',
                      onActionTap: () {
                        Navigator.pushNamed(context, '/all-products');
                      },
                    ),
                    const SizedBox(height: 12),
                    state.products.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No hay productos disponibles en este momento',
                                style: TextStyle(color: Color(0xFF9E9E9E)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _ProductsRow(products: state.products),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Cali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF6B6B6B),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Probar Devolución'),
                    content: const Text(
                      '¿Quieres probar la pantalla de devolución?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/return');
                        },
                        child: const Text('Sí'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.keyboard_return,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFF9E9E9E)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Buscar',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            ),
          ),
          SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    required this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 14,
              color: onActionTap != null
                  ? AppColors.primary
                  : const Color(0xFF6B6B6B),
              fontWeight: onActionTap != null
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<Map<String, String>> cats = const [
    {'label': 'Tecnología', 'icon': 'devices'},
    {'label': 'Deportes', 'icon': 'sports_soccer'},
    {'label': 'Ocasiones', 'icon': 'celebration'},
    {'label': 'Eventos', 'icon': 'camera_alt'},
    {'label': 'Hogar', 'icon': 'weekend'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = cats[index];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _mapIcon(item['icon']!),
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 72,
                child: Text(
                  item['label']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'devices':
        return Icons.phone_iphone;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'celebration':
        return Icons.emoji_events;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'weekend':
        return Icons.weekend;
      default:
        return Icons.category;
    }
  }
}

// Products row showing real available products
class _ProductsRow extends StatelessWidget {
  final List<Product> products;

  const _ProductsRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

// Product card for available products
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  String _formatPrice(int priceInCents) {
    final priceInPesos = priceInCents / 100;
    return '\$${priceInPesos.toStringAsFixed(0)}/día';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => ProductDetailBloc()),
                BlocProvider(create: (context) => RentalRequestBloc()),
              ],
              child: ProductDetailScreen(product: product),
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.photoUrl != null
                    ? Image.network(
                        product.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
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
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatPrice(product.pricePerDayCents),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
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
