import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/utils/currency_formatter.dart';
import 'package:wassali/features/customer/cart/presentation/providers/cart_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    double deliveryFee = 200;
    double total = cart.totalAmount + deliveryFee;

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('إتمام الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('عنوان التوصيل'),
            _buildAddressCard(context),
            const SizedBox(height: 32),
            _buildSectionTitle('طريقة الدفع'),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            _buildSectionTitle('ملخص الطلب'),
            _buildOrderBrief(cart, deliveryFee),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Process order creation via backend
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text(
                'تأكيد الطلب • ${CurrencyFormatter.format(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorTokens.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: ColorTokens.secondary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المنزل (القرارة)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('يرجى تحديد العنوان بدقة عند تأكيد الطلب', style: TextStyle(color: ColorTokens.textMuted, fontSize: 12)),
              ],
            ),
          ),
          TextButton(onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تغيير العنوان — قريباً')),
            );
          }, child: const Text('تغيير', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorTokens.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorTokens.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.money_rounded, color: ColorTokens.secondary),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نقدًا عند الاستلام', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('الدفع للسائق كاش بمجرد وصوله', style: TextStyle(color: ColorTokens.textMuted, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.check_circle_rounded, color: ColorTokens.secondary),
        ],
      ),
    );
  }

  Widget _buildOrderBrief(CartState cart, double deliveryFee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عدد المنتجات'),
              Text('${cart.itemCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع الفرعي'),
              Text(CurrencyFormatter.format(cart.totalAmount.toDouble()), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('رسوم التوصيل'),
              Text(CurrencyFormatter.format(deliveryFee), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي المستحق:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(CurrencyFormatter.format(cart.totalAmount + deliveryFee), style: const TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.secondary, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
