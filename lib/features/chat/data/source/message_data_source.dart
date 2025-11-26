import 'dart:async';
import 'package:lendly_app/domain/model/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MessageDataSource {
  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String content,
  );
  Future<List<Message>> getMessagesByConversation(String conversationId);
  Stream<Message> listenMessagesByConversation(String conversationId);
}

class MessageDataSourceImpl implements MessageDataSource {
  @override
  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    final message = await Supabase.instance.client
        .from("messages")
        .insert({
          "conversation_id": conversationId,
          "sender_id": senderId,
          "content": content,
        })
        .select()
        .single();

    return Message.fromJson(message);
  }

  @override
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    final list = await Supabase.instance.client
        .from("messages")
        .select()
        .eq("conversation_id", conversationId)
        .order("created_at", ascending: true);

    return (list as List).map((json) => Message.fromJson(json)).toList();
  }

  @override
  Stream<Message> listenMessagesByConversation(String conversationId) {
    final controller = StreamController<Message>();

    final channel = Supabase.instance.client
        .channel('public:messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: "conversation_id",
            value: conversationId,
          ),
          callback: (payload) {
            controller.add(Message.fromJson(payload.newRecord));
          },
        )
        .subscribe();

    controller.onCancel = () {
      Supabase.instance.client.removeChannel(channel);
    };

    return controller.stream;
  }
}

