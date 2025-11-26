import 'package:lendly_app/domain/model/message.dart';
import 'package:lendly_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/message_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<Message>> execute(String conversationId) async {
    return await repository.getMessagesByConversation(conversationId);
  }
}

