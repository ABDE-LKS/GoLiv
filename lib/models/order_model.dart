class OrderModel {
  final String id;
  final String customerId;
  final String? driverId;
  final String category;
  final String details;
  final String status;
  final String statusCode;
  final DateTime createdAt;
  final double totalAmount;

  OrderModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.category,
    required this.details,
    required this.status,
    required this.statusCode,
    required this.createdAt,
    required this.totalAmount,
  });

  static String _statusLabel(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'ACCEPTED':
        return 'مقبول';
      case 'PICKED_UP':
        return 'تم الاستلام';
      case 'DELIVERED':
        return 'تم التوصيل';
      case 'CANCELLED':
        return 'ملغى';
      default:
        return raw;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['statusCode'] ?? 'PENDING').toString();
    final statusCode = rawStatus.toLowerCase();
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      driverId: json['driverId'] as String?,
      category: json['category']?.toString() ?? 'طلب توصيل',
      details: json['details']?.toString() ??
          json['deliveryLocation']?.toString() ??
          json['pickupLocation']?.toString() ??
          '',
      status: _statusLabel(rawStatus),
      statusCode: statusCode,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get isActive =>
      statusCode != 'delivered' && statusCode != 'cancelled';

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? driverId,
    String? category,
    String? details,
    String? status,
    String? statusCode,
    DateTime? createdAt,
    double? totalAmount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      category: category ?? this.category,
      details: details ?? this.details,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
