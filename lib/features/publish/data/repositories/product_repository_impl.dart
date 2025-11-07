import 'dart:typed_data';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';
import 'package:lendly_app/features/publish/domain/repositories/product_repository.dart';
import 'package:lendly_app/features/publish/data/source/product_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource productDataSource = ProductDataSourceImpl();

  @override
  Future<Product> createProduct({
    required Product product,
    required List<Availability> availabilities,
    Object? photoBytes,
  }) async {
    try {
      String? photoUrl;

      if (photoBytes != null && photoBytes is Uint8List) {
        photoUrl = await productDataSource.uploadProductImage(
          photoBytes,
          '${product.title.replaceAll(' ', '_')}.jpg',
        );
      }

      final productToCreate = Product(
        ownerId: product.ownerId,
        title: product.title,
        description: product.description,
        category: product.category,
        pricePerDayCents: product.pricePerDayCents,
        condition: product.condition,
        country: product.country,
        city: product.city,
        address: product.address,
        pickupNotes: product.pickupNotes,
        photoUrl: photoUrl,
        active: product.active,
        isAvailable: product.isAvailable,
      );

      final createdProduct = await productDataSource.createProduct(
        productToCreate,
      );

      final availabilitiesWithItemId = availabilities.map((availability) {
        return Availability(
          itemId: createdProduct.id!,
          startDate: availability.startDate,
          endDate: availability.endDate,
          isBlocked: availability.isBlocked,
        );
      }).toList();

      await productDataSource.createAvailabilities(availabilitiesWithItemId);

      return createdProduct;
    } catch (e) {
      throw Exception('Error en el repositorio al crear producto: $e');
    }
  }

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    try {
      return await productDataSource.getUserProducts(userId);
    } catch (e) {
      throw Exception('Error en el repositorio al obtener productos: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      return await productDataSource.updateProduct(product.id!, product);
    } catch (e) {
      throw Exception('Error en el repositorio al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await productDataSource.deleteProduct(productId);
    } catch (e) {
      throw Exception('Error en el repositorio al eliminar producto: $e');
    }
  }
}
