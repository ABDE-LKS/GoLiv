import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../layout/admin_scaffold.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/live/presentation/live_operations_screen.dart';
import '../../features/stores/presentation/stores_screen.dart';
import '../../features/stores/presentation/store_details_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/drivers/presentation/drivers_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/offers/presentation/offers_screen.dart';
import '../../features/complaints/presentation/complaints_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/audit/presentation/audit_screen.dart';
import '../../features/admins/presentation/admins_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState.isAuthenticated;
      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      if (!loggedIn && !isLoginRoute) return '/login';
      if (loggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminScaffold(currentRoute: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/live', builder: (context, state) => const LiveOperationsScreen()),
          GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
          GoRoute(path: '/orders/:id', builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!)),
          GoRoute(path: '/drivers', builder: (context, state) => const DriversScreen()),
          GoRoute(path: '/customers', builder: (context, state) => const CustomersScreen()),
          GoRoute(path: '/stores', builder: (context, state) => const StoresScreen()),
          GoRoute(path: '/stores/:id', builder: (context, state) => StoreDetailsScreen(storeId: state.pathParameters['id']!)),
          GoRoute(path: '/products', builder: (context, state) => const ProductsScreen()),
          GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
          GoRoute(path: '/offers', builder: (context, state) => const OffersScreen()),
          GoRoute(path: '/complaints', builder: (context, state) => const ComplaintsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/audit', builder: (context, state) => const AuditScreen()),
          GoRoute(path: '/admins', builder: (context, state) => const AdminsScreen()),
        ],
      ),
    ],
  );
});
