import 'package:lendly_app/domain/model/conversation.dart';

abstract class ConversationRepository {
  Future<Conversation> findOrCreateConversation(
    String profile1Id,
    String profile2Id,
  );
  Future<List<Conversation>> getConversationsByUser(String userId);
}

