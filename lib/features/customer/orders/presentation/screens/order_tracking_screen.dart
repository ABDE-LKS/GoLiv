import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wassali/core/theme/color_tokens.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.map_rounded, size: 100, color: Colors.grey),
            ),
          ),
          
          _buildTopBar(context),
          _buildDraggableDriverCard(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('جاري التوصيل', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.secondary)),
                  Text('الوصول المتوقع: 14:55', style: TextStyle(fontSize: 12, color: ColorTokens.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableDriverCard() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: ColorTokens.info,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد بلقاسم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('تويوتا يارس • ABC 123', style: TextStyle(color: ColorTokens.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTokens.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_rounded, color: ColorTokens.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('حالة الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              _buildStatusTimeline(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: [
        _buildTimelineItem('تم استلام الطلب', '14:30', true),
        _buildTimelineItem('جاري التحضير', '14:35', true),
        _buildTimelineItem('جاري التوصيل', '14:45', true, isCurrent: true),
        _buildTimelineItem('تم التسليم', '--:--', false, isLast: true),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isDone, {bool isCurrent = false, bool isLast = false}) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Column(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isCurrent ? ColorTokens.secondary : (isDone ? ColorTokens.accent : Colors.grey.shade300),
                size: 24,
              ).animate(target: isCurrent ? 1 : 0)
                .shimmer(duration: 1.seconds, color: ColorTokens.secondary.withOpacity(0.5)),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? ColorTokens.accent : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? ColorTokens.secondary : (isDone ? Colors.black : Colors.grey),
                  ),
                ),
                Text(time, style: const TextStyle(fontSize: 12, color: ColorTokens.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


