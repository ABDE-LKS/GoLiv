import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/customer/home/presentation/screens/main_home_screen.dart';
import '../../features/customer/request/new_request_screen.dart';
import '../../features/customer/request/finding_driver_screen.dart';
import '../../features/customer/tracking/order_tracking_screen.dart';
import '../../features/customer/chat/chat_screen.dart';
import '../../features/customer/orders/presentation/screens/orders_history_screen.dart';
import '../../features/customer/favorites/presentation/screens/favorites_screen.dart';
import '../../features/customer/notifications/notification_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_tab_screen.dart';
import '../../features/customer/settings/settings_screen.dart';
import '../../features/customer/store/presentation/screens/stores_list_screen.dart';
import '../../features/customer/orders/presentation/custom_request_screen.dart';

class CustomerRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/customer/home',
      builder: (context, state) => const MainHomeScreen(),
    ),
    GoRoute(
      path: '/customer/request/new',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NewRequestScreen(),
        transitionsBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/customer/finding-driver',
      builder: (context, state) => const FindingDriverScreen(),
    ),
    GoRoute(
      path: '/customer/tracking',
      builder: (context, state) => const OrderTrackingScreen(),
    ),
    GoRoute(
      path: '/customer/chat/:orderId',
      builder: (context, state) => ChatScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),
    GoRoute(
      path: '/customer/orders',
      builder: (context, state) => const OrdersHistoryScreen(),
    ),
    GoRoute(
      path: '/customer/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/customer/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/customer/profile',
      builder: (context, state) => const ProfileTabScreen(),
    ),
    GoRoute(
      path: '/customer/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/customer/search',
      builder: (context, state) => const SearchStoresScreen(),
    ),
    GoRoute(
      path: '/custom-request',
      builder: (context, state) => const CustomRequestScreen(),
    ),
  ];
}
