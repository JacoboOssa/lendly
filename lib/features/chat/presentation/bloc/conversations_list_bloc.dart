import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/conversation.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/chat/data/repositories/conversation_repository_impl.dart';
import 'package:lendly_app/features/chat/data/source/conversation_data_source.dart';
import 'package:lendly_app/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';

// Events
abstract class ConversationsListEvent {}

class LoadConversationsEvent extends ConversationsListEvent {}

// States
abstract class ConversationsListState {}

class ConversationsListInitial extends ConversationsListState {}

class ConversationsListLoading extends ConversationsListState {}

class ConversationsListLoaded extends ConversationsListState {
  final List<ConversationWithUser> conversations;

  ConversationsListLoaded(this.conversations);
}

class ConversationsListError extends ConversationsListState {
  final String message;

  ConversationsListError(this.message);
}

// Model for UI
class ConversationWithUser {
  final Conversation conversation;
  final AppUser otherUser;

  ConversationWithUser({
    required this.conversation,
    required this.otherUser,
  });
}

// Bloc
class ConversationsListBloc
    extends Bloc<ConversationsListEvent, ConversationsListState> {
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GetConversationsUseCase getConversationsUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  ConversationsListBloc({
    GetCurrentUserUsecase? getCurrentUserUsecase,
    GetConversationsUseCase? getConversationsUseCase,
    GetUserProfileUseCase? getUserProfileUseCase,
  })  : getCurrentUserUsecase = getCurrentUserUsecase ?? GetCurrentUserUsecase(),
        getConversationsUseCase = getConversationsUseCase ??
            GetConversationsUseCase(
              ConversationRepositoryImpl(ConversationDataSourceImpl()),
            ),
        getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(
              ProfileDetailRepositoryImpl(ProfileDetailDataSourceImpl()),
            ),
        super(ConversationsListInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ConversationsListState> emit,
  ) async {
    emit(ConversationsListLoading());

    try {
      final currentUser = await getCurrentUserUsecase.execute();
      if (currentUser == null) {
        emit(ConversationsListError("Usuario actual no encontrado"));
        return;
      }

      final conversations =
          await getConversationsUseCase.execute(currentUser.id);

      // Get other user info for each conversation
      final List<ConversationWithUser> conversationsWithUsers = [];
      for (var conversation in conversations) {
        final otherUserId = conversation.getOtherUserId(currentUser.id);
        final otherUser = await getUserProfileUseCase.execute(otherUserId);
        if (otherUser != null) {
          conversationsWithUsers.add(
            ConversationWithUser(
              conversation: conversation,
              otherUser: otherUser,
            ),
          );
        }
      }

      emit(ConversationsListLoaded(conversationsWithUsers));
    } catch (e) {
      emit(ConversationsListError("Error al cargar conversaciones: ${e.toString()}"));
    }
  }
}

