import 'package:lendly_app/domain/model/rating.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RatingDataSource {
  Future<Rating> createRating(Rating rating);
  Future<List<Rating>> getRatingsByRentalId(String rentalId);
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type});
  Future<List<Rating>> getRatingsByProductId(String productId);
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type);
  
  // Paginated methods
  Future<List<Rating>> getRatingsByUserIdPaginated(
    String userId, {
    RatingType? type,
    int page = 0,
    int pageSize = 10,
  });
  Future<List<Rating>> getRatingsByProductIdPaginated(
    String productId, {
    int page = 0,
    int pageSize = 10,
  });
  
  // Average rating methods
  Future<double?> getUserAverageRating(String userId, {RatingType? type});
  Future<double?> getProductAverageRating(String productId);
}

class RatingDataSourceImpl implements RatingDataSource {
  @override
  Future<Rating> createRating(Rating rating) async {
    final response = await Supabase.instance.client
        .from('ratings')
        .insert(rating.toJson())
        .select()
        .single();

    return Rating.fromJson(response);
  }

  @override
  Future<List<Rating>> getRatingsByRentalId(String rentalId) async {
    final response = await Supabase.instance.client
        .from('ratings')
        .select()
        .eq('rental_id', rentalId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Rating.fromJson(json)).toList();
  }

  @override
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type}) async {
    var query = Supabase.instance.client
        .from('ratings')
        .select()
        .eq('rated_user_id', userId);

    if (type != null) {
      query = query.eq('rating_type', Rating.ratingTypeToDbString(type));
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => Rating.fromJson(json)).toList();
  }

  @override
  Future<List<Rating>> getRatingsByProductId(String productId) async {
    final response = await Supabase.instance.client
        .from('ratings')
        .select()
        .eq('product_id', productId)
        .eq('rating_type', 'product')
        .order('created_at', ascending: false);

    return (response as List).map((json) => Rating.fromJson(json)).toList();
  }

  @override
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type) async {
    final response = await Supabase.instance.client
        .from('ratings')
        .select()
        .eq('rental_id', rentalId)
        .eq('rater_user_id', raterUserId)
        .eq('rating_type', Rating.ratingTypeToDbString(type))
        .maybeSingle();

    if (response == null) return null;
    return Rating.fromJson(response);
  }

  @override
  Future<List<Rating>> getRatingsByUserIdPaginated(
    String userId, {
    RatingType? type,
    int page = 0,
    int pageSize = 10,
  }) async {
    final int start = page * pageSize;
    final int end = start + pageSize - 1;

    var query = Supabase.instance.client
        .from('ratings')
        .select()
        .eq('rated_user_id', userId);

    if (type != null) {
      query = query.eq('rating_type', Rating.ratingTypeToDbString(type));
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(start, end);

    return (response as List).map((json) => Rating.fromJson(json)).toList();
  }

  @override
  Future<List<Rating>> getRatingsByProductIdPaginated(
    String productId, {
    int page = 0,
    int pageSize = 10,
  }) async {
    final int start = page * pageSize;
    final int end = start + pageSize - 1;

    final response = await Supabase.instance.client
        .from('ratings')
        .select()
        .eq('product_id', productId)
        .eq('rating_type', 'product')
        .order('created_at', ascending: false)
        .range(start, end);

    return (response as List).map((json) => Rating.fromJson(json)).toList();
  }

  @override
  Future<double?> getUserAverageRating(String userId, {RatingType? type}) async {
    var query = Supabase.instance.client
        .from('ratings')
        .select('rating')
        .eq('rated_user_id', userId);

    if (type != null) {
      query = query.eq('rating_type', Rating.ratingTypeToDbString(type));
    }

    final response = await query;

    if (response.isEmpty) return null;

    final ratings = (response as List).map((r) => r['rating'] as int).toList();
    final sum = ratings.fold<int>(0, (a, b) => a + b);
    return sum / ratings.length;
  }

  @override
  Future<double?> getProductAverageRating(String productId) async {
    final response = await Supabase.instance.client
        .from('ratings')
        .select('rating')
        .eq('product_id', productId)
        .eq('rating_type', 'product');

    if (response.isEmpty) return null;

    final ratings = (response as List).map((r) => r['rating'] as int).toList();
    final sum = ratings.fold<int>(0, (a, b) => a + b);
    return sum / ratings.length;
  }
}

