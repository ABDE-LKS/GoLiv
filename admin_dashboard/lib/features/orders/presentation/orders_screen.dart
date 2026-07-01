import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../orders_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});
  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final isActing = ref.watch(orderActionProvider);
    final currentStatus = ref.watch(orderStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Orders Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildToolbar(currentStatus),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _buildError(err),
                  data: (orders) => orders.isEmpty ? _buildEmpty() : _buildTable(orders),
                ),
              ),
            ],
          ),
          if (isActing)
            Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
        ],
      ),
    );
  }

  Widget _buildToolbar(String currentStatus) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by Order ID, Customer Name, Phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); ref.read(orderSearchProvider.notifier).state = ''; setState(() {}); })
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: (v) => ref.read(orderSearchProvider.notifier).state = v.trim(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              initialValue: currentStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                DropdownMenuItem(value: 'ACCEPTED', child: Text('Accepted')),
                DropdownMenuItem(value: 'PICKED_UP', child: Text('Picked Up')),
                DropdownMenuItem(value: 'DELIVERED', child: Text('Delivered')),
                DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
              ],
              onChanged: (v) { if (v != null) ref.read(orderStatusFilterProvider.notifier).state = v; },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: () => ref.invalidate(ordersProvider)),
        ],
      ),
    );
  }

  Widget _buildTable(List<dynamic> orders) {
    return Card(
      margin: const EdgeInsets.all(24),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text('${orders.length} order(s)', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Driver', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Commission', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: orders.map<DataRow>((o) => _buildRow(o)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(dynamic order) {
    final customer = order['customer'];
    final driver = order['driver'];
    final status = order['status'] ?? 'PENDING';
    final dateStr = DateFormat('MM-dd HH:mm').format(DateTime.parse(order['createdAt']));
    final shortId = (order['id'] as String).length > 8 ? (order['id'] as String).substring(0, 8) : order['id'];

    return DataRow(cells: [
      DataCell(Text('#$shortId', style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
      DataCell(Text(customer != null ? '${customer['firstName']} ${customer['lastName']}' : 'N/A')),
      DataCell(Text(driver != null ? '${driver['user']['firstName']} ${driver['user']['lastName']}' : 'Unassigned',
          style: TextStyle(color: driver == null ? Colors.orange : null))),
      DataCell(Text('${order['totalAmount']} دج', style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text('${order['deliveryFee']} دج')),
      DataCell(Text('${order['commission']} دج')),
      DataCell(_statusBadge(status)),
      DataCell(Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        Tooltip(message: 'View Details', child: IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 20),
          onPressed: () => context.go('/orders/${order['id']}'),
        )),
        if (status == 'PENDING')
          Tooltip(message: 'Assign Driver', child: IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.teal, size: 20),
            onPressed: () => _showAssignDriverDialog(order['id']),
          )),
        if (status != 'DELIVERED' && status != 'CANCELLED')
          Tooltip(message: 'Cancel Order', child: IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
            onPressed: () => _confirmCancel(order['id']),
          )),
      ])),
    ]);
  }

  Widget _statusBadge(String status) {
    final colors = {
      'PENDING': Colors.orange,
      'ACCEPTED': Colors.blue,
      'PICKED_UP': Colors.indigo,
      'DELIVERED': Colors.green,
      'CANCELLED': Colors.red,
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _confirmCancel(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel this order?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. The customer will be notified.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(orderActionProvider.notifier).cancelOrder(orderId);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled'), backgroundColor: Colors.green));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showAssignDriverDialog(String orderId) {
    showDialog(
      context: context,
      builder: (_) => _AssignDriverDialog(orderId: orderId),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No orders found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Try changing your filters.', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Failed to load orders', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('$err', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'), onPressed: () => ref.invalidate(ordersProvider)),
        ],
      ),
    );
  }
}

// ========================
// ASSIGN DRIVER DIALOG
// ========================
class _AssignDriverDialog extends ConsumerWidget {
  final String orderId;
  const _AssignDriverDialog({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(availableDriversProvider);
    final isActing = ref.watch(orderActionProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Assign Driver', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        height: 300,
        child: driversAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading drivers: $e'),
          data: (drivers) {
            if (drivers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No drivers online', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (ctx, i) {
                final d = drivers[i];
                final user = d['user'];
                return ListTile(
                  leading: CircleAvatar(child: Text('${user['firstName'][0]}${user['lastName'][0]}')),
                  title: Text('${user['firstName']} ${user['lastName']}'),
                  subtitle: Text(user['phone'] ?? ''),
                  trailing: isActing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(orderActionProvider.notifier).assignDriver(orderId, d['id']);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Driver assigned'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          child: const Text('Assign'),
                        ),
                );
              },
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
