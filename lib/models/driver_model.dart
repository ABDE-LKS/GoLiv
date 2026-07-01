import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String id,
    required String name,
    required String phone,
    required double rating,
    required int totalDeliveries,
    required bool isOnline,
    required String vehicleType,
    required String vehiclePlate,
    required String zone,
    required int todayEarnings,
    required int commissionOwed,
    required String joinedAt,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);
}
