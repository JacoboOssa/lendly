import 'package:lendly_app/domain/model/conversation.dart';
import 'package:lendly_app/features/chat/data/source/conversation_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationDataSource dataSource;

  ConversationRepositoryImpl(this.dataSource);

  @override
  Future<Conversation> findOrCreateConversation(
    String profile1Id,
    String profile2Id,
  ) async {
    Conversation? conversation = await dataSource.findConversation(
      profile1Id,
      profile2Id,
    );

    if (conversation != null) {
      return conversation;
    } else {
      return await dataSource.createConversation(profile1Id, profile2Id);
    }
  }

  @override
  Future<List<Conversation>> getConversationsByUser(String userId) {
    return dataSource.getConversationsByUser(userId);
  }
}

