import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../stores_provider.dart';
import 'edit_store_dialog.dart';

class StoreDetailsScreen extends ConsumerWidget {
  final String storeId;
  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/stores'),
        ),
        title: const Text('Store Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Failed to load store', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text('$err', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.invalidate(storeDetailProvider(storeId)),
              ),
            ],
          ),
        ),
        data: (store) => _StoreDetailsBody(store: store, storeId: storeId),
      ),
    );
  }
}

class _StoreDetailsBody extends ConsumerWidget {
  final Map<String, dynamic> store;
  final String storeId;
  const _StoreDetailsBody({required this.store, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = store['isActive'] ?? true;
    final bool isFeatured = store['isFeatured'] ?? false;
    final String createdAt = store['createdAt'] != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(store['createdAt']))
        : 'N/A';
    final products = store['products'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Card ---
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: store['logo'] != null && store['logo'].toString().isNotEmpty
                        ? NetworkImage(store['logo'])
                        : null,
                    child: store['logo'] == null || store['logo'].toString().isEmpty
                        ? const Icon(Icons.store, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 24),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(store['name'] ?? '',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            _statusBadge(isActive),
                            if (isFeatured) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 14),
                                    SizedBox(width: 4),
                                    Text('Featured', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(store['category']?['name'] ?? 'No Category',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(store['address'] ?? '',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditStoreDialog(store: store),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 16),
                        label: Text(isActive ? 'Suspend' : 'Activate'),
                        onPressed: () async {
                          try {
                            await ref.read(storeActionProvider.notifier).suspendStore(storeId, !isActive);
                            ref.invalidate(storeDetailProvider(storeId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isActive ? 'Store suspended' : 'Store activated'),
                                  backgroundColor: Colors.green,
                                ),
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive ? Colors.orange : Colors.green,
                        ),
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
              // Left Column — Store Information
              Expanded(
                flex: 2,
                child: Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Store Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        _infoRow('Phone', store['phone'] ?? '-'),
                        _infoRow('Delivery Fee', '${store['deliveryFee'] ?? 0} دج'),
                        _infoRow('Min Delivery Time', '${store['minDeliveryTime'] ?? 0} min'),
                        _infoRow('Max Delivery Time', '${store['maxDeliveryTime'] ?? 0} min'),
                        _infoRow('Rating', '${store['rating'] ?? 0.0}'),
                        _infoRow('Created At', createdAt),
                        if (store['description'] != null && store['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(store['description'], style: TextStyle(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right Column — Products summary
              Expanded(
                flex: 3,
                child: Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Products (${products.length})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24),
                        if (products.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('No products yet', style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          )
                        else
                          ...products.take(10).map<Widget>((p) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: p['image'] != null && p['image'].toString().isNotEmpty
                                  ? NetworkImage(p['image'])
                                  : null,
                              child: p['image'] == null || p['image'].toString().isEmpty
                                  ? const Icon(Icons.fastfood, size: 16)
                                  : null,
                            ),
                            title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${p['price']} دج'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: p['isActive'] == true
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p['isActive'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: p['isActive'] == true ? Colors.green : Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
