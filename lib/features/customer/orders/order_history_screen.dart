import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/features/customer/orders/orders_provider.dart';
import 'package:wassali/models/order_model.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/price_tag.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
          bottom: TabBar(
            isScrollable: true,
            labelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelSmall,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: ColorTokens.accent,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'نشط'),
              Tab(text: 'مكتمل'),
              Tab(text: 'ملغى'),
            ],
          ),
        ),
        body: ordersAsync.when(
          data: (orders) => TabBarView(
            children: [
              _buildOrderList(orders),
              _buildOrderList(orders.where((o) => ['pending', 'accepted', 'delivering'].contains(o.statusCode)).toList()),
              _buildOrderList(orders.where((o) => o.statusCode == 'delivered').toList()),
              _buildOrderList(orders.where((o) => o.statusCode == 'cancelled').toList()),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('حدث خطأ: $e'),
                TextButton(
                  onPressed: () => ref.invalidate(ordersProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_basket_outlined, size: 64, color: ColorTokens.textMuted),
            const SizedBox(height: 16),
            const Text('لا توجد طلبات هنا', style: TextStyle(color: ColorTokens.textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final status = order.status;
    final statusColor = _getStatusColor(order.statusCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ColorTokens.background, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shopping_basket, color: ColorTokens.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب #${order.id.substring(0, 8)}', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(order.createdAt.toString(), style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجمالي المبلغ', style: TextStyle(fontSize: 10, color: ColorTokens.textMuted)),
                  PriceTag(amount: order.totalAmount.toDouble(), size: PriceTagSize.medium, color: ColorTokens.textPrimary),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (order.isActive) context.push('/customer/tracking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.secondary.withOpacity(0.1),
                  foregroundColor: ColorTokens.secondary,
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('تفاصيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String code) {
    switch (code) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'delivering': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}



