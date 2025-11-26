import 'package:lendly_app/domain/model/message.dart';
import 'package:lendly_app/features/chat/data/source/message_data_source.dart';
import 'package:lendly_app/features/chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageDataSource dataSource;

  MessageRepositoryImpl(this.dataSource);

  @override
  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    return await dataSource.sendMessage(conversationId, senderId, content);
  }

  @override
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    return await dataSource.getMessagesByConversation(conversationId);
  }

  @override
  Stream<Message> listenMessages(String conversationId) {
    return dataSource.listenMessagesByConversation(conversationId);
  }
}

