import 'package:lendly_app/domain/model/rating.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RatingDataSource {
  Future<Rating> createRating(Rating rating);
  Future<List<Rating>> getRatingsByRentalId(String rentalId);
  Future<List<Rating>> getRatingsByUserId(String userId, {RatingType? type});
  Future<List<Rating>> getRatingsByProductId(String productId);
  Future<Rating?> getRatingByRentalAndType(String rentalId, String raterUserId, RatingType type);
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
}

