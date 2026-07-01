import '../models/driver_model.dart';

abstract class IDriverRepository {
  Future<List<DriverModel>> getDrivers();
  Future<DriverModel> getDriverById(String id);
  Future<void> updateDriverStatus(String id, bool isOnline);
}
