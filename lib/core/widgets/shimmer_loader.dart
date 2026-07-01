import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/color_tokens.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget orderCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 20),
    );
  }

  static Widget categoryChip() {
    return const Padding(
      padding: EdgeInsets.only(left: 12),
      child: ShimmerLoader(width: 80, height: 40, borderRadius: 20),
    );
  }
}
