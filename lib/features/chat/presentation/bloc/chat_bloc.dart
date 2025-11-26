import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/domain/model/message.dart';
import 'package:lendly_app/domain/model/conversation.dart';
import 'package:lendly_app/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:lendly_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/conversation_data_source.dart';
import 'package:lendly_app/features/chat/data/source/message_data_source.dart';
import 'package:lendly_app/features/chat/domain/usecases/find_or_create_conversation_usecase.dart';
import 'package:lendly_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:lendly_app/features/chat/domain/usecases/listen_messages_usecase.dart';
import 'package:lendly_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class ChatEvent {}

class InitializeChatEvent extends ChatEvent {
  final AppUser otherUser;

  InitializeChatEvent({required this.otherUser});
}

class SendMessageEvent extends ChatEvent {
  final String content;

  SendMessageEvent({required this.content});
}

class ChatNewMessageArriveEvent extends ChatEvent {
  final Message message;

  ChatNewMessageArriveEvent({required this.message});
}

// States
abstract class ChatState {
  final List<Message> messages;
  final String? meId;
  final String? otherId;
  final String? conversation;

  ChatState({
    this.messages = const [],
    this.meId,
    this.otherId,
    this.conversation,
  });
}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  ChatLoadedState({
    super.messages,
    super.meId,
    super.otherId,
    super.conversation,
  });
}

class ChatErrorState extends ChatState {
  final String message;

  ChatErrorState({required this.message});
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final FindOrCreateConversationUseCase findOrCreateConversationUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ListenMessagesUseCase listenMessagesUseCase;
  StreamSubscription<Message>? _messageSubscription;

  ChatBloc({
    GetCurrentUserUsecase? getCurrentUserUsecase,
    FindOrCreateConversationUseCase? findOrCreateConversationUseCase,
    GetMessagesUseCase? getMessagesUseCase,
    SendMessageUseCase? sendMessageUseCase,
    ListenMessagesUseCase? listenMessagesUseCase,
  })  : getCurrentUserUsecase = getCurrentUserUsecase ?? GetCurrentUserUsecase(),
        findOrCreateConversationUseCase = findOrCreateConversationUseCase ??
            FindOrCreateConversationUseCase(
              ConversationRepositoryImpl(ConversationDataSourceImpl()),
            ),
        getMessagesUseCase = getMessagesUseCase ??
            GetMessagesUseCase(
              MessageRepositoryImpl(MessageDataSourceImpl()),
            ),
        sendMessageUseCase = sendMessageUseCase ??
            SendMessageUseCase(
              MessageRepositoryImpl(MessageDataSourceImpl()),
            ),
        listenMessagesUseCase = listenMessagesUseCase ??
            ListenMessagesUseCase(
              MessageRepositoryImpl(MessageDataSourceImpl()),
            ),
        super(ChatInitialState()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<SendMessageEvent>(_onSendMessage);
    on<ChatNewMessageArriveEvent>(_onMessageArrived);
  }

  void _onMessageArrived(
    ChatNewMessageArriveEvent event,
    Emitter<ChatState> emit,
  ) {
    var currentState = state;

    emit(
      ChatLoadedState(
        messages: [...currentState.messages, event.message],
        meId: currentState.meId,
        otherId: currentState.otherId,
        conversation: currentState.conversation,
      ),
    );
  }

  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());

    final me = await getCurrentUserUsecase.execute();
    if (me == null) {
      emit(ChatErrorState(message: "Usuario actual no encontrado"));
      return;
    }

    try {
      Conversation conversation = await findOrCreateConversationUseCase.execute(
        me.id,
        event.otherUser.id,
      );

      var messages = await getMessagesUseCase.execute(conversation.id);

      emit(
        ChatLoadedState(
          messages: messages,
          meId: me.id,
          otherId: event.otherUser.id,
          conversation: conversation.id,
        ),
      );

      // Listen to new messages
      _messageSubscription?.cancel();
      _messageSubscription = listenMessagesUseCase.execute(conversation.id).listen(
        (data) {
          add(ChatNewMessageArriveEvent(message: data));
        },
      );
    } catch (e) {
      emit(ChatErrorState(message: "Error al inicializar el chat: ${e.toString()}"));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (state.conversation == null || state.meId == null) {
      return;
    }

    try {
      await sendMessageUseCase.execute(
        state.conversation!,
        state.meId!,
        event.content,
      );
    } catch (e) {
      emit(ChatErrorState(message: "Error al enviar mensaje: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

