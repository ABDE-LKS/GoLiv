import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardStatsProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Business Overview',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 24),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorState(ref, err.toString()),
                data: (data) => _buildDashboardGrid(data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(dashboardStatsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(Map<String, dynamic> data) {
    final orders = data['orders'] ?? {};
    final users = data['users'] ?? {};
    final marketplace = data['marketplace'] ?? {};
    final financials = data['financials'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Financials & Economics'),
        GridView.extent(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
             _StatCard(title: "Today's Revenue", value: '${financials['todaysRevenue']} دج', icon: Icons.attach_money, color: Colors.green),
             _StatCard(title: "Total Commission", value: '${financials['totalCommission']} دج', icon: Icons.percent, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 32),

        _buildSectionTitle('Order Activity'),
        GridView.extent(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _StatCard(title: "Today's Orders", value: orders['today'].toString(), icon: Icons.receipt_long, color: Colors.indigo),
            _StatCard(title: "Pending", value: orders['pending'].toString(), icon: Icons.pending_actions, color: Colors.orange),
            _StatCard(title: "Shopping", value: orders['shopping'].toString(), icon: Icons.shopping_cart, color: Colors.blueAccent),
            _StatCard(title: "Delivering", value: orders['delivering'].toString(), icon: Icons.two_wheeler, color: Colors.lightBlue),
            _StatCard(title: "Completed", value: orders['completed'].toString(), icon: Icons.check_circle, color: Colors.teal),
            _StatCard(title: "Cancelled", value: orders['cancelled'].toString(), icon: Icons.cancel, color: Colors.red),
          ],
        ),
        const SizedBox(height: 32),

        _buildSectionTitle('Fleet & Users'),
        GridView.extent(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _StatCard(title: "Total Customers", value: users['customers'].toString(), icon: Icons.people, color: Colors.purple),
            _StatCard(title: "Total Drivers", value: users['totalDrivers'].toString(), icon: Icons.sports_motorsports, color: Colors.deepPurple),
            _StatCard(title: "Online Drivers", value: users['onlineDrivers'].toString(), icon: Icons.bolt, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 32),

        _buildSectionTitle('Marketplace Entities'),
        GridView.extent(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _StatCard(title: "Total Stores", value: marketplace['stores'].toString(), icon: Icons.storefront, color: Colors.brown),
            _StatCard(title: "Total Products", value: marketplace['products'].toString(), icon: Icons.fastfood, color: Colors.redAccent),
            _StatCard(title: "Active Offers", value: marketplace['activeOffers'].toString(), icon: Icons.local_offer, color: Colors.pink),
            _StatCard(title: "Open Complaints", value: (marketplace['openComplaints'] ?? 0).toString(), icon: Icons.feedback, color: Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
