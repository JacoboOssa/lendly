import 'package:lendly_app/domain/model/conversation.dart';
import 'package:lendly_app/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/conversation_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/conversation_repository.dart';

class FindOrCreateConversationUseCase {
  final ConversationRepository repository;

  FindOrCreateConversationUseCase(this.repository);

  Future<Conversation> execute(String profile1Id, String profile2Id) async {
    return await repository.findOrCreateConversation(profile1Id, profile2Id);
  }
}

