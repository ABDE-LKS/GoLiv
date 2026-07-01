import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final isActing = ref.watch(orderActionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/orders')),
        title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          orderAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Failed to load order', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Text('$err', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                  ),
                ],
              ),
            ),
            data: (order) => _OrderDetailBody(order: order, orderId: orderId),
          ),
          if (isActing)
            Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
        ],
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final Map<String, dynamic> order;
  final String orderId;
  const _OrderDetailBody({required this.order, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = order['customer'] as Map<String, dynamic>?;
    final driver = order['driver'] as Map<String, dynamic>?;
    final driverUser = driver?['user'] as Map<String, dynamic>?;
    final statusHistory = order['statusHistory'] as List? ?? [];
    final status = order['status'] ?? 'PENDING';
    final createdAt = order['createdAt'] != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(order['createdAt']))
        : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Order #${orderId.substring(0, 8)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            const SizedBox(width: 16),
                            _statusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Created: $createdAt', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Row(
                    children: [
                      if (status != 'DELIVERED' && status != 'CANCELLED')
                        _buildStatusButton(context, ref, status),
                      const SizedBox(width: 8),
                      if (status != 'DELIVERED' && status != 'CANCELLED')
                        OutlinedButton.icon(
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancel'),
                          onPressed: () => _confirmCancel(context, ref),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Info Grid ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info
              Expanded(
                child: _infoCard('Customer', [
                  _row('Name', customer != null ? '${customer['firstName']} ${customer['lastName']}' : 'N/A'),
                  _row('Phone', customer?['phone'] ?? 'N/A'),
                  _row('Email', customer?['email'] ?? 'N/A'),
                ]),
              ),
              const SizedBox(width: 24),

              // Driver Info
              Expanded(
                child: _infoCard('Driver', [
                  if (driverUser != null) ...[
                    _row('Name', '${driverUser['firstName']} ${driverUser['lastName']}'),
                    _row('Phone', driverUser['phone'] ?? 'N/A'),
                  ] else
                    const Text('No driver assigned', style: TextStyle(color: Colors.orange)),
                ]),
              ),
              const SizedBox(width: 24),

              // Financial Info
              Expanded(
                child: _infoCard('Financial', [
                  _row('Total Amount', '${order['totalAmount']} دج'),
                  _row('Delivery Fee', '${order['deliveryFee']} دج'),
                  _row('Commission', '${order['commission']} دج'),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Locations ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoCard('Locations', [
                  _row('Pickup', order['pickupLocation'] ?? 'N/A'),
                  _row('Delivery', order['deliveryLocation'] ?? 'N/A'),
                  if (order['pickupTime'] != null)
                    _row('Pickup Time', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(order['pickupTime']))),
                  if (order['deliveryTime'] != null)
                    _row('Delivery Time', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(order['deliveryTime']))),
                ]),
              ),
              const SizedBox(width: 24),

              // Timeline
              Expanded(
                flex: 2,
                child: _infoCard('Status Timeline', [
                  if (statusHistory.isEmpty)
                    const Text('No status history', style: TextStyle(color: Colors.grey))
                  else
                    ...statusHistory.map<Widget>((h) {
                      final ts = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(h['timestamp']));
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _statusDot(h['status']),
                            const SizedBox(width: 12),
                            Text(h['status'], style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(ts, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, WidgetRef ref, String currentStatus) {
    final nextStatus = _getNextStatus(currentStatus);
    if (nextStatus == null) return const SizedBox.shrink();

    return ElevatedButton.icon(
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: Text('Move to $nextStatus'),
      onPressed: () async {
        try {
          await ref.read(orderActionProvider.notifier).updateStatus(orderId, nextStatus);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status updated to $nextStatus'), backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
          }
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white),
    );
  }

  String? _getNextStatus(String current) {
    switch (current) {
      case 'PENDING': return 'ACCEPTED';
      case 'ACCEPTED': return 'PICKED_UP';
      case 'PICKED_UP': return 'DELIVERED';
      default: return null;
    }
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel this order?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(orderActionProvider.notifier).cancelOrder(orderId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final colors = {
      'PENDING': Colors.orange, 'ACCEPTED': Colors.blue, 'PICKED_UP': Colors.indigo,
      'DELIVERED': Colors.green, 'CANCELLED': Colors.red,
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusDot(String status) {
    final colors = {
      'PENDING': Colors.orange, 'ACCEPTED': Colors.blue, 'PICKED_UP': Colors.indigo,
      'DELIVERED': Colors.green, 'CANCELLED': Colors.red,
    };
    return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[status] ?? Colors.grey));
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
