// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalDeliveries: (json['totalDeliveries'] as num).toInt(),
      isOnline: json['isOnline'] as bool,
      vehicleType: json['vehicleType'] as String,
      vehiclePlate: json['vehiclePlate'] as String,
      zone: json['zone'] as String,
      todayEarnings: (json['todayEarnings'] as num).toInt(),
      commissionOwed: (json['commissionOwed'] as num).toInt(),
      joinedAt: json['joinedAt'] as String,
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'rating': instance.rating,
      'totalDeliveries': instance.totalDeliveries,
      'isOnline': instance.isOnline,
      'vehicleType': instance.vehicleType,
      'vehiclePlate': instance.vehiclePlate,
      'zone': instance.zone,
      'todayEarnings': instance.todayEarnings,
      'commissionOwed': instance.commissionOwed,
      'joinedAt': instance.joinedAt,
    };
