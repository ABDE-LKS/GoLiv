import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/core/network/socket_service.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:wassali/models/conversation_model.dart';

// --- Providers ---

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<ChatMessageModel>, String>((ref, conversationId) {
  return ChatMessagesNotifier(ref, conversationId);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageModel>> {
  final Ref _ref;
  final String _conversationId;
  StreamSubscription? _socketSubscription;

  ChatMessagesNotifier(this._ref, this._conversationId) : super([]) {
    _fetchMessages();
    _listenToSocket();
  }

  Future<void> _fetchMessages() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/conversations/$_conversationId/messages');
      final List data = response.data;
      state = data.map((e) => ChatMessageModel.fromJson(e)).toList();
      
      // Mark as read when entering
      _ref.read(socketServiceProvider).emitMarkAsRead(_conversationId);
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void _listenToSocket() {
    final socket = _ref.read(socketServiceProvider);
    socket.joinConversation(_conversationId);
    
    socket.on('newMessage', (data) {
      final message = ChatMessageModel.fromJson(data);
      // Avoid duplicates and replace optimistic temporary messages
      final isDuplicateOrOptimistic = state.any((m) => 
        m.id == message.id || 
        (m.senderId == message.senderId && m.content == message.content && m.id.length < 20) // ID < 20 indicates our timestamp-based temp ID
      );

      if (isDuplicateOrOptimistic) {
        state = state.map((m) => 
          (m.id == message.id || (m.senderId == message.senderId && m.content == message.content && m.id.length < 20))
          ? message : m
        ).toList();
      } else {
        state = [...state, message];
      }
      
      // Mark as read if I am the receiver
      final currentUserId = _ref.read(authNotifierProvider).userId;
      if (message.senderId != currentUserId) {
        socket.emitMarkAsRead(_conversationId);
      }
    });

    socket.on('messagesSeen', (data) {
      if (data['conversationId'] == _conversationId) {
        state = state.map((m) => m.copyWith(isRead: true)).toList();
      }
    });
  }

  void addMessageOptimistically(ChatMessageModel message) {
    state = [...state, message];
  }

  @override
  void dispose() {
    _ref.read(socketServiceProvider).off('newMessage');
    _ref.read(socketServiceProvider).off('messagesSeen');
    super.dispose();
  }
}

final typingProvider = StateProvider.family<bool, String>((ref, conversationId) {
  final socket = ref.watch(socketServiceProvider);
  bool isTyping = false;
  
  socket.on('userTyping', (data) {
    if (data['conversationId'] == conversationId && data['userId'] != ref.read(authNotifierProvider).userId) {
      // This is a bit simplified, usually you'd want a map of users typing
    }
  });
  
  return isTyping;
});

// --- UI ---

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? adTitle;
  final String? adImage;

  const ChatScreen({
    super.key, 
    required this.conversationId, 
    this.adTitle,
    this.adImage,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTypingLocally = false;
  Timer? _typingTimer;
  bool _showOtherTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socketServiceProvider).connect();
    });
    
    // Setup typing listener manually here or via provider
    final socket = ref.read(socketServiceProvider);
    socket.on('userTyping', (data) {
      if (data['conversationId'] == widget.conversationId && data['userId'] != ref.read(authNotifierProvider).userId) {
        if (mounted) setState(() => _showOtherTyping = data['isTyping']);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTypingLocally) {
      _isTypingLocally = true;
      ref.read(socketServiceProvider).emitTyping(widget.conversationId, true);
    }
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isTypingLocally) {
        _isTypingLocally = false;
        ref.read(socketServiceProvider).emitTyping(widget.conversationId, false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    _isTypingLocally = false;
    ref.read(socketServiceProvider).emitTyping(widget.conversationId, false);
    
    // Add optimistically for instant feedback
    final authState = ref.read(authNotifierProvider);
    final optimisticMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temporary ID
      content: text,
      senderId: authState.userId ?? '',
      createdAt: DateTime.now(),
      isRead: false,
    );
    ref.read(chatMessagesProvider(widget.conversationId).notifier).addMessageOptimistically(optimisticMsg);
    
    // Send via socket
    ref.read(socketServiceProvider).sendMessage(widget.conversationId, text);
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final messages = ref.watch(chatMessagesProvider(widget.conversationId));

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (widget.adTitle != null) _buildAdPreview(),
          Expanded(
            child: messages.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.senderId == authState.userId;
                    
                    // Logic for date separators
                    bool showDate = false;
                    if (index == 0) {
                      showDate = true;
                    } else {
                      final prevMsg = messages[index - 1];
                      if (msg.createdAt.day != prevMsg.createdAt.day) {
                        showDate = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(msg.createdAt),
                        _buildChatBubble(msg, isMe),
                      ],
                    );
                  },
                ),
          ),
          if (_showOtherTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ColorTokens.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: ColorTokens.primary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 20, color: ColorTokens.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المحادثة',
                  style: TextStyle(color: ColorTokens.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _showOtherTyping ? 'يكتب الآن...' : 'متصل',
                  style: TextStyle(
                    color: _showOtherTyping ? ColorTokens.primary : Colors.green,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert_rounded, color: ColorTokens.textPrimary), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAdPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          if (widget.adImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.adImage!, width: 45, height: 45, fit: BoxFit.cover),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('بخصوص الإعلان:', style: TextStyle(fontSize: 11, color: ColorTokens.textMuted)),
                Text(
                  widget.adTitle!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('عرض الإعلان', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatSeparatorDate(date),
            style: const TextStyle(fontSize: 11, color: ColorTokens.textMuted, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? ColorTokens.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: isMe ? const Radius.circular(22) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.white : ColorTokens.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  intl.DateFormat('HH:mm').format(msg.createdAt),
                  style: const TextStyle(color: ColorTokens.textMuted, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: msg.isRead ? Colors.blue : ColorTokens.textMuted,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: ColorTokens.primary),
          ),
          const SizedBox(width: 8),
          Text(
            'يكتب الآن...',
            style: TextStyle(fontSize: 12, color: ColorTokens.primary.withOpacity(0.7), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: ColorTokens.background, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: ColorTokens.primary),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTextChanged,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                hintStyle: const TextStyle(color: ColorTokens.textMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                filled: true,
                fillColor: ColorTokens.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: ColorTokens.primary,
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 70, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('ابدأ المحادثة الآن', style: TextStyle(color: ColorTokens.textMuted, fontWeight: FontWeight.bold)),
          const Text('للاتفاق على السعر وموعد الاستلام', style: TextStyle(color: ColorTokens.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatSeparatorDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'اليوم';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year) {
      return 'أمس';
    }
    return intl.DateFormat('dd MMMM yyyy', 'ar').format(date);
  }
}
