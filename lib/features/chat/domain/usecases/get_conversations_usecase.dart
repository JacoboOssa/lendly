import 'package:lendly_app/domain/model/conversation.dart';
import 'package:lendly_app/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/conversation_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/conversation_repository.dart';

class GetConversationsUseCase {
  final ConversationRepository repository;

  GetConversationsUseCase(this.repository);

  Future<List<Conversation>> execute(String userId) async {
    return await repository.getConversationsByUser(userId);
  }
}

