import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/customer/home/presentation/screens/main_home_screen.dart';
import '../../features/customer/advertisements/presentation/screens/create_ad_screen.dart';
import '../../features/customer/advertisements/presentation/screens/search_ads_screen.dart';
import '../../features/customer/advertisements/presentation/screens/ad_details_screen.dart';
import '../../features/customer/notifications/notification_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_tab_screen.dart';
import '../../features/customer/settings/settings_screen.dart';
import 'package:wassali/shared/presentation/screens/coming_soon_screen.dart';

import '../../features/customer/chat/conversations_list_screen.dart';

class CustomerRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/customer/home',
      builder: (context, state) => const MainHomeScreen(),
    ),
    GoRoute(
      path: '/customer/search',
      builder: (context, state) => const SearchAdsScreen(),
    ),
    GoRoute(
      path: '/customer/ad/create',
      builder: (context, state) => const CreateAdScreen(),
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
    // Common / Feature placeholders
    GoRoute(
      path: '/customer/chats',
      builder: (context, state) => const ConversationsListScreen(),
    ),
  ];
}
