import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final reportsSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final res = await ref.watch(apiClientProvider).dio.get('/reports/summary');
  return Map<String, dynamic>.from(res.data as Map);
});

final reportsExportProvider = FutureProvider.autoDispose<String>((ref) async {
  final res = await ref.watch(apiClientProvider).dio.get('/reports/export/orders');
  return res.data.toString();
});
