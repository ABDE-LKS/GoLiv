import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/repositories/store_repository_impl.dart';

final storeProductsProvider = FutureProvider.family((ref, String storeId) {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getStoreProducts(storeId);
});

