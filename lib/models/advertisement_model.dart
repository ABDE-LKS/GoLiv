import 'package:wassali/models/category_model.dart';

enum AdvertisementCondition { new_condition, used_like_new, used_good, used_fair }

class AdvertisementModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool isNegotiable;
  final String? condition;
  final List<String> images;
  final String categoryId;
  final String sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String location;
  final String status;
  final int views;
  final DateTime createdAt;
  final bool isFavorite;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.isNegotiable = false,
    this.condition,
    required this.images,
    required this.categoryId,
    required this.sellerId,
    this.sellerName,
    this.sellerPhone,
    required this.location,
    required this.status,
    this.views = 0,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      isNegotiable: json['isNegotiable'] ?? false,
      condition: json['condition'],
      images: (json['images'] as List?)?.map((e) => e['url'] as String).toList() ?? [],
      categoryId: json['categoryId'],
      sellerId: json['sellerId'],
      sellerName: json['seller'] != null 
          ? '${json['seller']['firstName']} ${json['seller']['lastName']}' 
          : json['sellerName'],
      sellerPhone: json['seller']?['phone'] ?? json['sellerPhone'],
      location: json['location'] ?? 'القرارة',
      status: json['status'] ?? 'ACTIVE',
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
