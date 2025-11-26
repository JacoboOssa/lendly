import 'dart:typed_data';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/availability.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class ProductDataSource {
  Future<Product> createProduct(Product product);
  Future<void> createAvailabilities(List<Availability> availabilities);
  Future<String> uploadProductImage(Uint8List imageBytes, String fileName);
  Future<List<Product>> getUserProducts(String userId);
  Future<Product> updateProduct(String productId, Product product);
  Future<void> deleteProduct(String productId);
}

class ProductDataSourceImpl extends ProductDataSource {
  final Uuid _uuid = const Uuid();

  @override
  Future<Product> createProduct(Product product) async {
    final response = await Supabase.instance.client
        .from('items')
        .insert(product.toJson())
        .select()
        .single();

    return Product.fromJson(response);
  }

  @override
  Future<void> createAvailabilities(List<Availability> availabilities) async {
    final availabilitiesData = availabilities.map((a) => a.toJson()).toList();
    await Supabase.instance.client
        .from('availability')
        .insert(availabilitiesData);
  }

  @override
  Future<String> uploadProductImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final path = _uuid.v4();

    await Supabase.instance.client.storage
        .from('product_images')
        .uploadBinary(path, imageBytes);

    final imageUrl = Supabase.instance.client.storage
        .from('product_images')
        .getPublicUrl(path);

    return imageUrl;
  }

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    final response = await Supabase.instance.client
        .from('items')
        .select()
        .eq('owner_id', userId)
        .eq('active', true) // Solo productos activos (no eliminados)
        .order('created_at', ascending: false);

    return (response as List).map((data) => Product.fromJson(data)).toList();
  }

  @override
  Future<Product> updateProduct(String productId, Product product) async {
    final response = await Supabase.instance.client
        .from('items')
        .update(product.toJson())
        .eq('id', productId)
        .select()
        .single();

    return Product.fromJson(response);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    // Soft delete: actualizar active = false en lugar de eliminar físicamente
    await Supabase.instance.client
        .from('items')
        .update({'active': false})
        .eq('id', productId);
  }
}
