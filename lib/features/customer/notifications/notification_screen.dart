import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import 'notifications_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when opening the screen
    Future.microtask(() {
      ref.read(notificationsNotifierProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsNotifierProvider),
        child: notificationsAsync.when(
          data: (list) => list.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: Text('لا توجد إشعارات', style: AppTextStyles.bodyMedium)),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final notification = list[index];
                    return _buildNotificationItem(notification);
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(child: Text('خطأ في تحميل الإشعارات', style: AppTextStyles.bodyMedium)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
    final isRead = notification.isRead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : ColorTokens.secondary.withOpacity(0.03),
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorTokens.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined, color: ColorTokens.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                Text('منذ قليل', style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: ColorTokens.textMuted)),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: ColorTokens.secondary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}


