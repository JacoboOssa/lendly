import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/chat/presentation/bloc/conversations_list_bloc.dart';
import 'package:lendly_app/features/chat/presentation/screens/chat_conversation_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversationsListBloc()..add(LoadConversationsEvent()),
      child: const _ChatsView(),
    );
  }
}

class _ChatsView extends StatelessWidget {
  const _ChatsView();

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
                      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatsHeader(onBackPressed: () => Navigator.pop(context)),
            const SizedBox(height: 8),
            _SearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ConversationsListBloc, ConversationsListState>(
                builder: (context, state) {
                  if (state is ConversationsListLoading) {
                    return const Center(
                      child: LoadingSpinner(),
                    );
                  }
                  if (state is ConversationsListError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ConversationsListLoaded) {
                    if (state.conversations.isEmpty) {
                      return _EmptyChats();
                    }
                    return _ChatsList(
                      conversations: state.conversations,
                      formatTimestamp: _formatTimestamp,
                    );
                  }
                  return _EmptyChats();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Header con botón de regreso y título
class _ChatsHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _ChatsHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: onBackPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Barra de búsqueda
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar conversaciones...',
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9E9E9E),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ),
    );
  }
}

// Widget: Lista de chats vacía
class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay conversaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia una conversación con otros usuarios',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Lista de chats
class _ChatsList extends StatelessWidget {
  final List<ConversationWithUser> conversations;
  final String Function(DateTime) formatTimestamp;

  const _ChatsList({
    required this.conversations,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ChatCard(
          conversationWithUser: conversations[index],
          formatTimestamp: formatTimestamp,
        );
      },
    );
  }
}

// Widget: Tarjeta individual de chat
class _ChatCard extends StatelessWidget {
  final ConversationWithUser conversationWithUser;
  final String Function(DateTime) formatTimestamp;

  const _ChatCard({
    required this.conversationWithUser,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = conversationWithUser.otherUser;
    final conversation = conversationWithUser.conversation;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(otherUser: otherUser),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _ChatAvatar(name: otherUser.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherUser.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatTimestamp(conversation.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Avatar del contacto
class _ChatAvatar extends StatelessWidget {
  final String name;

  const _ChatAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF555879),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

