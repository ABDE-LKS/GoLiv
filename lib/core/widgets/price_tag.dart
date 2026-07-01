import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../theme/text_styles.dart';

enum PriceTagSize { small, medium, large }

class PriceTag extends StatelessWidget {
  final num amount;
  final PriceTagSize size;
  final Color? color;

  const PriceTag({
    super.key,
    required this.amount,
    this.size = PriceTagSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    return Text(
      CurrencyFormatter.format(amount.toDouble()),
      style: style.copyWith(color: color),
      textDirection: TextDirection.rtl,
    );
  }

  TextStyle _getStyle() {
    switch (size) {
      case PriceTagSize.small:
        return AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold);
      case PriceTagSize.medium:
        return AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold);
      case PriceTagSize.large:
        return AppTextStyles.priceLarge;
    }
  }
}
