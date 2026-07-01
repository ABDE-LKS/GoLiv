import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../live_operations_provider.dart';

class LiveOperationsScreen extends ConsumerStatefulWidget {
  const LiveOperationsScreen({super.key});

  @override
  ConsumerState<LiveOperationsScreen> createState() => _LiveOperationsScreenState();
}

class _LiveOperationsScreenState extends ConsumerState<LiveOperationsScreen> {
  // To handle dynamic side panel toggling
  bool _showDriversPanel = true;

  @override
  Widget build(BuildContext context) {
    final liveDataAsync = ref.watch(liveOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Operations Control Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_showDriversPanel ? Icons.people : Icons.people_outline),
            tooltip: 'Toggle Drivers Panel',
            color: Colors.indigo,
            onPressed: () => setState(() => _showDriversPanel = !_showDriversPanel),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: liveDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Connection lost: $err'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.refresh(liveOperationsProvider), child: const Text('Reconnect')),
            ],
          ),
        ),
        data: (data) {
          final orders = data['orders'] as List? ?? [];
          final drivers = data['drivers'] as List? ?? [];

          // Grouping logic based on Prisma Enum (PENDING, ACCEPTED, PICKED_UP, DELIVERED, CANCELLED)
          final pending = orders.where((o) => o['status'] == 'PENDING').toList();
          final accepted = orders.where((o) => o['status'] == 'ACCEPTED').toList();
          final shopping = []; // Prisma doesn't have shopping currently, mapping strictly
          final delivering = orders.where((o) => o['status'] == 'PICKED_UP').toList();
          final delivered = orders.where((o) => o['status'] == 'DELIVERED').toList();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Kanban Board
              Expanded(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKanbanColumn('Waiting Driver', pending, Colors.orange),
                        _buildKanbanColumn('Driver Accepted', accepted, Colors.blue),
                        _buildKanbanColumn('Shopping', shopping, Colors.indigo), // Placeholder for prompt requirement
                        _buildKanbanColumn('Delivering', delivering, Colors.purple),
                        _buildKanbanColumn('Delivered Today', delivered, Colors.green),
                      ],
                    ),
                  ),
                ),
              ),

              // Drivers Side Panel
              if (_showDriversPanel)
                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(left: BorderSide(color: Colors.black12)),
                  ),
                  child: _buildDriversPanel(drivers),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List orders, Color headerColor) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: headerColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: headerColor, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Column Cards
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], headerColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, Color statusColor) {
    final customer = order['customer'] ?? {};
    final driver = order['driver']?['user'] ?? {};
    final String orderId = order['id'].toString().substring(0, 8);

    // Calculate elapsed time strictly simply
    final createdTime = DateTime.parse(order['createdAt']);
    final elapsedMinutes = DateTime.now().difference(createdTime).inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#$orderId', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: elapsedMinutes > 45 ? Colors.red : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${elapsedMinutes}m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: elapsedMinutes > 45 ? Colors.red : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Customer & Driver
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${customer['firstName']} ${customer['lastName']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.two_wheeler, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  driver.isNotEmpty ? '${driver['firstName']} ${driver['lastName']}' : 'Unassigned',
                  style: TextStyle(color: driver.isNotEmpty ? Colors.black87 : Colors.orange, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${order['totalAmount']} دج', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Dialog open placeholder
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor.withOpacity(0.1),
                  foregroundColor: statusColor,
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriversPanel(List drivers) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo.withOpacity(0.05),
          child: const Row(
            children: [
              Icon(Icons.sports_motorsports, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Fleet Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: drivers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final driver = drivers[index];
              final user = driver['user'] ?? {};
              return ListTile(
                leading: Badge(
                  backgroundColor: driver['isOnline'] ? Colors.green : Colors.grey,
                  child: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(user['firstName']?.substring(0, 1) ?? 'D', style: const TextStyle(color: Colors.indigo)),
                  ),
                ),
                title: Text('${user['firstName']} ${user['lastName']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(driver['isOnline'] ? 'Available' : 'Offline', style: TextStyle(fontSize: 12, color: driver['isOnline'] ? Colors.green : Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  onPressed: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
