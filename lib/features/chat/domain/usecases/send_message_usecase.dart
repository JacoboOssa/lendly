import 'package:lendly_app/domain/model/message.dart';
import 'package:lendly_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/message_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository repository;

  SendMessageUseCase(this.repository);

  Future<Message> execute(
    String conversationId,
    String senderId,
    String content,
  ) async {
    return await repository.sendMessage(conversationId, senderId, content);
  }
}

