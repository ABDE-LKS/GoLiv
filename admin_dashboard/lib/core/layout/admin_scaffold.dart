import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';

class AdminScaffold extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AdminScaffold({super.key, required this.child, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Guliv Admin',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem(context, 'Dashboard', Icons.dashboard, '/dashboard'),
                      _buildMenuItem(context, 'Live Operations', Icons.satellite_alt, '/live'),
                      _buildMenuItem(context, 'Orders', Icons.receipt_long, '/orders'),
                      _buildMenuItem(context, 'Drivers', Icons.two_wheeler, '/drivers'),
                      _buildMenuItem(context, 'Customers', Icons.people, '/customers'),
                      _buildMenuItem(context, 'Stores', Icons.storefront, '/stores'),
                      _buildMenuItem(context, 'Products', Icons.fastfood, '/products'),
                      _buildMenuItem(context, 'Categories', Icons.category, '/categories'),
                      _buildMenuItem(context, 'Offers', Icons.local_offer, '/offers'),
                      _buildMenuItem(context, 'Complaints', Icons.feedback, '/complaints'),
                      _buildMenuItem(context, 'Notifications', Icons.notifications, '/notifications'),
                      _buildMenuItem(context, 'Reports', Icons.bar_chart, '/reports'),
                      _buildMenuItem(context, 'Settings', Icons.settings, '/settings'),
                      _buildMenuItem(context, 'Audit Logs', Icons.history, '/audit'),
                      _buildMenuItem(context, 'Admins', Icons.admin_panel_settings, '/admins'),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white54),
                  title: const Text('Logout', style: TextStyle(color: Colors.white70)),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2C3E50),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        ref.watch(authProvider).role ?? 'Admin',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Page Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    final isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.white : Colors.white54),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        context.go(route);
      },
    );
  }
}
