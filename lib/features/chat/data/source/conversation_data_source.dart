import 'package:lendly_app/domain/model/conversation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ConversationDataSource {
  Future<Conversation?> findConversation(String profile1Id, String profile2Id);
  Future<Conversation> createConversation(String profile1Id, String profile2Id);
  Future<List<Conversation>> getConversationsByUser(String userId);
}

class ConversationDataSourceImpl implements ConversationDataSource {
  @override
  Future<Conversation?> findConversation(
    String profile1Id,
    String profile2Id,
  ) async {
    final result = await Supabase.instance.client
        .from("conversations")
        .select()
        .or(
          'and(profile1_id.eq.$profile1Id,profile2_id.eq.$profile2Id),and(profile1_id.eq.$profile2Id,profile2_id.eq.$profile1Id)',
        )
        .maybeSingle();

    if (result != null) {
      return Conversation.fromJson(result);
    } else {
      return null;
    }
  }

  @override
  Future<Conversation> createConversation(
    String profile1Id,
    String profile2Id,
  ) async {
    final result = await Supabase.instance.client
        .from("conversations")
        .insert({
          "profile1_id": profile1Id,
          "profile2_id": profile2Id,
        })
        .select()
        .single();

    return Conversation.fromJson(result);
  }

  @override
  Future<List<Conversation>> getConversationsByUser(String userId) async {
    final result = await Supabase.instance.client
        .from("conversations")
        .select()
        .or('profile1_id.eq.$userId,profile2_id.eq.$userId')
        .order('created_at', ascending: false);

    return (result as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
  }
}

