import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_animate/flutter_animate.dart';
import 'notifications_provider.dart';
import '../../../models/notification_model.dart';
import '../../../repositories/notification_repository_impl.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ColorTokens.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: ColorTokens.primary),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () async {
              await ref.read(notificationsNotifierProvider.notifier).markAllRead();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذر تحميل الإشعارات'),
              TextButton(onPressed: () => ref.read(notificationsNotifierProvider.notifier).refresh(), child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                    child: Icon(Icons.notifications_off_outlined, size: 64, color: ColorTokens.primary.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 24),
                  const Text('لا توجد إشعارات', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 8),
                  const Text('ليس لديك أي إشعارات جديدة حالياً', style: TextStyle(color: ColorTokens.textMuted)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationCard(notification: notif, ref: ref).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final WidgetRef ref;

  const _NotificationCard({required this.notification, required this.ref});

  Widget _getIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'ORDER':
      case 'AD_SOLD':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'MESSAGE':
        icon = Icons.chat_bubble_outline;
        color = Colors.blue;
        break;
      case 'SYSTEM':
      case 'BROADCAST':
        icon = Icons.campaign_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications_none;
        color = ColorTokens.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
          ref.read(notificationsNotifierProvider.notifier).refresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900, fontSize: 15),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (notification.body.isNotEmpty)
                    Text(
                      notification.body,
                      style: TextStyle(color: ColorTokens.textMuted, fontSize: 13, fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      if (difference.inMinutes == 0) return 'الآن';
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    }
    return intl.DateFormat('dd MMMM yyyy', 'ar').format(date);
  }
}
