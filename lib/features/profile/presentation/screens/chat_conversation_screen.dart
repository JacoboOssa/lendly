import 'package:flutter/material.dart';

class ChatConversationScreen extends StatefulWidget {
  final String contactName;
  final bool isOnline;

  const ChatConversationScreen({
    super.key,
    required this.contactName,
    required this.isOnline,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Datos de prueba - En producción vendrían de un BLoC
  final List<Message> messages = [
    Message(
      text: "Hola, ¿cómo estás?",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      text: "Hola! Todo bien, ¿y tú?",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 58)),
    ),
    Message(
      text: "¿Todavía está disponible la cámara que publicaste?",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    Message(
      text: "Sí, está disponible. ¿Te interesa alquilarla?",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
    ),
    Message(
      text: "Perfecto, me gustaría alquilarla por una semana. ¿Cuál sería el precio total?",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    Message(
      text: "El precio es \$50 por día, entonces por una semana serían \$350. ¿Te parece bien?",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),
    Message(
      text: "Sí, perfecto. ¿Cuándo podemos coordinar la entrega?",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        Message(
          text: _messageController.text,
          isSentByMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              contactName: widget.contactName,
              isOnline: widget.isOnline,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _MessagesList(
                messages: messages,
                scrollController: _scrollController,
              ),
            ),
            _MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: Header del chat
class _ChatHeader extends StatelessWidget {
  final String contactName;
  final bool isOnline;
  final VoidCallback onBackPressed;

  const _ChatHeader({
    required this.contactName,
    required this.isOnline,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF555879),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    contactName.isNotEmpty ? contactName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'En línea' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF555879),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget: Lista de mensajes
class _MessagesList extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTimestamp = index == 0 ||
            message.timestamp.difference(messages[index - 1].timestamp).inMinutes > 30;

        return Column(
          children: [
            if (showTimestamp) _TimeStampDivider(timestamp: message.timestamp),
            _MessageBubble(message: message),
          ],
        );
      },
    );
  }
}

// Widget: Divisor con timestamp
class _TimeStampDivider extends StatelessWidget {
  final DateTime timestamp;

  const _TimeStampDivider({required this.timestamp});

  String _formatTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
                      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatTimestamp(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}

// Widget: Burbuja de mensaje
class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSentByMe) const SizedBox(width: 0),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isSentByMe
                    ? const Color(0xFF555879)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isSentByMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isSentByMe
                          ? Colors.white
                          : const Color(0xFF2C2C2C),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isSentByMe
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isSentByMe) const SizedBox(width: 0),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Widget: Input de mensaje
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF9E9E9E),
                      size: 22,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2C2C2C),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(onPressed: onSend),
        ],
      ),
    );
  }
}

// Widget: Botón de enviar
class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF555879),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.send,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// Modelo de datos para mensaje
class Message {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
  });
}
