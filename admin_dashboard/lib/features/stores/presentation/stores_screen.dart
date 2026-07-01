import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../stores_provider.dart';
import '../../categories/categories_provider.dart';
import 'create_store_dialog.dart';
import 'edit_store_dialog.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(storeSearchProvider.notifier).state = value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storesProvider);
    final isPerformingAction = ref.watch(storeActionProvider);
    final currentStatus = ref.watch(storeStatusFilterProvider);
    final currentCategory = ref.watch(storeCategoryFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Stores Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Store'),
            onPressed: () {
              showDialog(context: context, builder: (_) => const CreateStoreDialog());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // --- Toolbar: Search + Filters ---
              _buildToolbar(currentStatus, currentCategory),
              // --- Data Table ---
              Expanded(
                child: storesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => _buildErrorState(err),
                  data: (stores) => stores.isEmpty ? _buildEmptyState() : _buildDataTable(stores),
                ),
              ),
            ],
          ),
          if (isPerformingAction)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // ========================
  // TOOLBAR
  // ========================
  Widget _buildToolbar(String currentStatus, String? currentCategory) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: _onSearch,
              onChanged: (v) => setState(() {}), // rebuild to show/hide clear icon
            ),
          ),
          const SizedBox(width: 16),

          // Status Filter
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
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
              ],
              onChanged: (val) {
                if (val != null) ref.read(storeStatusFilterProvider.notifier).state = val;
              },
            ),
          ),
          const SizedBox(width: 16),

          // Category Filter
          Expanded(
            flex: 1,
            child: categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, s) => const Text('Error'),
              data: (cats) {
                final items = <DropdownMenuItem<String>>[
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...cats.map<DropdownMenuItem<String>>((c) =>
                    DropdownMenuItem(value: c['id'] as String, child: Text(c['name'] as String))),
                ];
                return DropdownButtonFormField<String>(
                  initialValue: currentCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: items,
                  onChanged: (val) => ref.read(storeCategoryFilterProvider.notifier).state = val,
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(storesProvider),
          ),
        ],
      ),
    );
  }

  // ========================
  // DATA TABLE
  // ========================
  Widget _buildDataTable(List<dynamic> stores) {
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
            child: Text('${stores.length} store(s) found', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Store', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Delivery Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Time (min)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Featured', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: stores.map<DataRow>((store) => _buildStoreRow(store)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildStoreRow(dynamic store) {
    final bool isActive = store['isActive'] ?? true;
    final bool isFeatured = store['isFeatured'] ?? false;
    final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(store['createdAt']));
    final int minTime = store['minDeliveryTime'] ?? 0;
    final int maxTime = store['maxDeliveryTime'] ?? 0;

    return DataRow(
      cells: [
        // Store Name + Logo
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: store['logo'] != null && store['logo'].toString().isNotEmpty
                  ? NetworkImage(store['logo'])
                  : null,
              child: store['logo'] == null || store['logo'].toString().isEmpty
                  ? const Icon(Icons.store, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (store['address'] != null)
                  Text(store['address'], style: TextStyle(fontSize: 11, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        )),

        // Category
        DataCell(Text(store['category']?['name'] ?? 'N/A')),

        // Phone
        DataCell(Text(store['phone'] ?? '-')),

        // Delivery Fee
        DataCell(Text('${store['deliveryFee']} دج',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),

        // Delivery Time
        DataCell(Text('$minTime - $maxTime')),

        // Status Badge
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Active' : 'Suspended',
            style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        )),

        // Featured Toggle
        DataCell(Switch(
          value: isFeatured,
          onChanged: (val) async {
            try {
              await ref.read(storeActionProvider.notifier).featureStore(store['id'], val);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? 'Store featured on home page' : 'Store removed from home page'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
          activeThumbColor: Colors.amber,
          activeTrackColor: Colors.amber.withValues(alpha: 0.4),
        )),

        // Created At
        DataCell(Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12))),

        // Actions
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View
            Tooltip(
              message: 'View Details',
              child: IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 20),
                onPressed: () => context.go('/stores/${store['id']}'),
              ),
            ),
            // Edit
            Tooltip(
              message: 'Edit Store',
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                onPressed: () {
                  showDialog(context: context, builder: (_) => EditStoreDialog(store: store));
                },
              ),
            ),
            // Suspend / Activate
            Tooltip(
              message: isActive ? 'Suspend Store' : 'Activate Store',
              child: IconButton(
                icon: Icon(
                  isActive ? Icons.block : Icons.check_circle_outline,
                  color: isActive ? Colors.grey : Colors.green,
                  size: 20,
                ),
                onPressed: () => _confirmAction(
                  title: isActive ? 'Suspend Store?' : 'Activate Store?',
                  message: isActive
                      ? 'This store will be hidden from customers. You can reactivate it later.'
                      : 'This store will become visible to customers again.',
                  confirmLabel: isActive ? 'Suspend' : 'Activate',
                  confirmColor: isActive ? Colors.orange : Colors.green,
                  onConfirm: () async {
                    try {
                      await ref.read(storeActionProvider.notifier).suspendStore(store['id'], !isActive);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isActive ? 'Store suspended' : 'Store activated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            // Delete
            Tooltip(
              message: 'Delete Store',
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmAction(
                  title: 'Delete Store Permanently?',
                  message: 'This action cannot be undone. All products and offers associated with this store will also be removed.',
                  confirmLabel: 'Delete',
                  confirmColor: Colors.red,
                  onConfirm: () async {
                    try {
                      await ref.read(storeActionProvider.notifier).deleteStore(store['id']);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Store deleted'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  // ========================
  // EMPTY STATE
  // ========================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No stores found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Try changing your filters or create a new store.', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Store'),
            onPressed: () => showDialog(context: context, builder: (_) => const CreateStoreDialog()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // ERROR STATE
  // ========================
  Widget _buildErrorState(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Failed to load stores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('$err', style: TextStyle(color: Colors.grey[500], fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => ref.invalidate(storesProvider),
          ),
        ],
      ),
    );
  }

  // ========================
  // CONFIRM DIALOG
  // ========================
  void _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
