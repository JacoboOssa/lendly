import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rented/presentation/bloc/rented_products_bloc.dart';
import 'package:lendly_app/features/rented/presentation/widgets/rented_product_card.dart';
import 'package:lendly_app/features/rented/domain/usecases/get_rented_products_usecase.dart';
import 'package:lendly_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:lendly_app/features/checkout/presentation/screens/checkout_screen.dart';

class RentedProductsScreen extends StatelessWidget {
  const RentedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentedProductsBloc()..add(LoadRentedProductsEvent()),
      child: const _RentedProductsView(),
    );
  }
}

class _RentedProductsView extends StatelessWidget {
  const _RentedProductsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<RentedProductsBloc, RentedProductsState>(
          builder: (context, state) {
            if (state is RentedProductsLoaded) {
              return Text(
                state.isBorrower ? 'Productos alquilados' : 'Productos en alquiler',
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return const Text(
              'Productos alquilados',
              style: TextStyle(
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<RentedProductsBloc, RentedProductsState>(
        builder: (context, state) {
          if (state is RentedProductsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B5670)),
              ),
            );
          }

          if (state is RentedProductsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is RentedProductsLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.isBorrower
                          ? 'No tienes productos alquilados'
                          : 'No tienes productos en alquiler',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final productData = state.products[index];
                return RentedProductCard(
                  productData: productData,
                  isBorrower: state.isBorrower,
                  onChat: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          otherUser: productData.otherUser,
                        ),
                      ),
                    );
                  },
                  onReturn: () => Navigator.pushNamed(context, '/return-product'),
                  onPay: productData.payment != null && !productData.payment!.paid
                      ? () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(payment: productData.payment!),
                            ),
                          );
                          // Si el pago fue exitoso, recargar la lista
                          if (result == true && context.mounted) {
                            context.read<RentedProductsBloc>().add(LoadRentedProductsEvent());
                          }
                        }
                      : null,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ReturnProductScreen extends StatelessWidget {
  const ReturnProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devolución'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2C2C2C),
      ),
      body: const Center(child: Text('Proceso de devolución (placeholder)')),
    );
  }
}
