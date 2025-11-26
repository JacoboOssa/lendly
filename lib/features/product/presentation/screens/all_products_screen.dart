import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:lendly_app/core/widgets/app_bar_custom.dart';
import 'package:lendly_app/core/widgets/skeleton_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/features/product/presentation/bloc/all_products_bloc.dart';
import 'package:lendly_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:lendly_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:lendly_app/features/product/presentation/bloc/rental_request_bloc.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AllProductsBloc>().add(LoadAllProducts(isInitialLoad: true));
  }

  String _formatPrice(int priceInCents) {
    final priceInPesos = priceInCents / 100;
    return '\$${priceInPesos.toStringAsFixed(0)}/día';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Todos los productos',
      ),
      body: BlocBuilder<AllProductsBloc, AllProductsState>(
        builder: (context, state) {
          if (state is AllProductsLoading) {
            return const ProductsSkeletonLoader(itemCount: 10);
          }

          if (state is AllProductsError) {
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

          if (state is AllProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text(
                  'No hay productos disponibles',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                ),
              );
            }

            // Dividir productos en dos columnas
            final leftColumn = <Product>[];
            final rightColumn = <Product>[];

            for (int i = 0; i < state.products.length; i++) {
              if (i % 2 == 0) {
                leftColumn.add(state.products[i]);
              } else {
                rightColumn.add(state.products[i]);
              }
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Columna izquierda
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: leftColumn
                                      .map(
                                        (product) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: _ProductCard(
                                            product: product,
                                            formatPrice: _formatPrice,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Columna derecha
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: rightColumn
                                      .map(
                                        (product) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: _ProductCard(
                                            product: product,
                                            formatPrice: _formatPrice,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Navegación de páginas
                    _PaginationControls(
                      currentPage: state.currentPage,
                      totalPages: state.totalPages,
                      isLoading: state.isLoading,
                    ),
                  ],
                ),
                // Overlay de carga cuando está paginando
                if (state.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: LoadingSpinner(),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String Function(int) formatPrice;

  const _ProductCard({required this.product, required this.formatPrice});

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
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del producto
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.photoUrl != null
                    ? Image.network(
                        product.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
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
                                size: 48,
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
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            // Información del producto
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(product.pricePerDayCents),
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

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón Anterior (solo icono)
          _IconNavigationButton(
            icon: Icons.arrow_back_ios_new,
            enabled: currentPage > 0 && !isLoading,
            onTap: () {
              context.read<AllProductsBloc>().add(PreviousPage());
            },
          ),

          const SizedBox(width: 20),

          // Indicador de página (siempre visible)
          Text(
            'Página ${currentPage + 1} de $totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1F1F),
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(width: 20),

          // Botón Siguiente (solo icono)
          _IconNavigationButton(
            icon: Icons.arrow_forward_ios,
            enabled: currentPage < totalPages - 1 && !isLoading,
            onTap: () {
              context.read<AllProductsBloc>().add(NextPage());
            },
          ),
        ],
      ),
    );
  }
}

// Botón de navegación solo con icono (compacto)
class _IconNavigationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _IconNavigationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF6B5B7C), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: enabled ? null : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white : const Color(0xFFBDBDBD),
          ),
        ),
      ),
    );
  }
}
