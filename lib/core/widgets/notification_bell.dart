import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/customer/notifications/notifications_provider.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadNotificationsCountProvider);
    final count = countAsync; // unreadNotificationsCountProvider is sync in my implementation

    return GestureDetector(
      onTap: () => context.push('/customer/notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_outlined, size: 24),
          ),
          if (count > 0)
            Positioned(
              top: 6,
              left: 4, // RTL: left is visual right
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  ).then().scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: const Duration(milliseconds: 600),
                  ),
            ),
        ],
      ),
    );
  }
}
