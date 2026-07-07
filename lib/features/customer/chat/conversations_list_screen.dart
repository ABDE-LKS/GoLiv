import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/models/conversation_model.dart';
import 'package:wassali/features/customer/chat/chat_screen.dart';

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/conversations');
  final List data = response.data;
  return data.map((e) => ConversationModel.fromJson(e)).toList();
});

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('عذراً، حدث خطأ أثناء تحميل المحادثات')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لا توجد محادثات بعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('ابدأ المحادثة مع البائعين للسؤال عن الإعلانات', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 24, thickness: 0.5),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(conversationId: conv.id, adTitle: conv.adTitle),
                  ),
                ),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: conv.adImage != null ? DecorationImage(image: NetworkImage(conv.adImage!), fit: BoxFit.cover) : null,
                  ),
                  child: conv.adImage == null ? const Icon(Icons.inventory_2_outlined, color: Colors.grey) : null,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(conv.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      DateFormat('HH:mm').format(conv.updatedAt),
                      style: const TextStyle(fontSize: 12, color: ColorTokens.textMuted),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.adTitle ?? 'بدون عنوان',
                        style: TextStyle(fontSize: 13, color: ColorTokens.primary.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conv.lastMessage,
                        style: TextStyle(fontSize: 14, color: ColorTokens.textPrimary.withOpacity(0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
