import '../models/store_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class IStoreRepository {
  Future<List<StoreModel>> getAllStores();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<ProductModel>> getStoreProducts(String storeId);
}
