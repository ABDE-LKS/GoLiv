import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/utils/currency_formatter.dart';
import 'package:wassali/features/customer/cart/presentation/providers/cart_provider.dart';
import 'package:wassali/models/product_model.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('سلة المشتريات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cart.items.isEmpty 
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(ref, item.product, item.quantity);
                    },
                  ),
                ),
                _buildSummary(context, cart),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('سلتك فارغة حالياً', style: TextStyle(color: ColorTokens.textMuted, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCartItem(WidgetRef ref, ProductModel product, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(CurrencyFormatter.format(product.price.toDouble()), style: const TextStyle(color: ColorTokens.secondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      ref.read(cartProvider.notifier).removeProduct(product.id);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      ref.read(cartProvider.notifier).addProduct(product);
                    }),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: ColorTokens.error),
            onPressed: () {
              ref.read(cartProvider.notifier).removeProduct(product.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: ColorTokens.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: ColorTokens.primary),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartState cart) {
    double deliveryFee = 200;
    double total = cart.totalAmount + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          _buildSummaryRow('المجموع الفرعي', CurrencyFormatter.format(cart.totalAmount.toDouble())),
          const SizedBox(height: 12),
          _buildSummaryRow('رسوم التوصيل', CurrencyFormatter.format(deliveryFee)),
          const Divider(height: 32),
          _buildSummaryRow('الإجمالي', CurrencyFormatter.format(total), isTotal: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (cart.items.isEmpty) return;
              
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text('تأكيد الطلب', textAlign: TextAlign.right),
                    content: const Text('هل أنت متأكد من إتمام الطلب؟', textAlign: TextAlign.right),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          // Simulating checkout success
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
                          );
                          // We'll pop back
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.secondary),
                        child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.secondary,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: const Text('المتابعة لإتمام الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: isTotal ? Colors.black : ColorTokens.textMuted,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          fontSize: isTotal ? 18 : 14,
        )),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isTotal ? 20 : 14,
          color: isTotal ? ColorTokens.secondary : Colors.black,
        )),
      ],
    );
  }
}
