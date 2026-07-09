import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/models/conversation_model.dart';
import 'package:wassali/features/customer/chat/chat_screen.dart';
import 'package:wassali/features/auth/auth_state.dart';

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authNotifierProvider);
  if (authState.userId == null) return [];
  
  final response = await apiClient.dio.get('/conversations');
  final List data = response.data;
  return data.map((e) => ConversationModel.fromJson(e, authState.userId!)).toList();
});

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'المحادثات',
                style: TextStyle(color: ColorTokens.textPrimary, fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: ColorTokens.textPrimary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: conversationsAsync.when(
              loading: () => _buildLoadingList(),
              error: (e, _) => _buildErrorState(),
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return _ConversationTile(conv: conv);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(radius: 28, backgroundColor: Colors.grey[100]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 12, color: Colors.grey[100]),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 10, color: Colors.grey[100]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[200]),
          const SizedBox(height: 16),
          const Text('فشل في تحميل المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('تأكد من اتصالك بالإنترنت وحاول مرة أخرى', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 24),
          const Text('لا توجد محادثات بعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          const Text(
            'تواصل مع البائعين لتبدأ أولى صفقاتك!',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;

  const _ConversationTile({required this.conv});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversationId: conv.id, adTitle: conv.adTitle),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: conv.otherUserProfilePhoto != null
                            ? DecorationImage(image: NetworkImage(conv.otherUserProfilePhoto!), fit: BoxFit.cover)
                            : null,
                        color: ColorTokens.primary.withOpacity(0.1),
                      ),
                      child: conv.otherUserProfilePhoto == null
                          ? const Icon(Icons.person, color: ColorTokens.primary)
                          : null,
                    ),
                    if (conv.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conv.otherUserName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorTokens.textPrimary),
                          ),
                          Text(
                            _formatDate(conv.updatedAt),
                            style: const TextStyle(fontSize: 11, color: ColorTokens.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (conv.adTitle != null)
                        Text(
                          conv.adTitle!,
                          style: TextStyle(fontSize: 12, color: ColorTokens.primary.withOpacity(0.8), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: conv.unreadCount > 0 ? ColorTokens.textPrimary : ColorTokens.textMuted,
                                fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.adImage != null) ...[
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(conv.adImage!, width: 20, height: 20, fit: BoxFit.cover),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd/MM').format(date);
  }
}
