class ServiceCategoryModel {
  final String id;
  final String name;
  final String? icon;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

class ServiceModel {
  final String id;
  final String providerId;
  final String categoryId;
  final String title;
  final String description;
  final String city;
  final double? price;
  final String? experience;
  final String? availability;
  final double rating;
  final int viewsCount;
  final String status;
  final DateTime createdAt;
  
  final List<String> images;
  final String? providerName;
  final String? providerPhone;
  final String? providerPhoto;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.city,
    this.price,
    this.experience,
    this.availability,
    required this.rating,
    required this.viewsCount,
    required this.status,
    required this.createdAt,
    required this.images,
    this.providerName,
    this.providerPhone,
    this.providerPhoto,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'];
    final imageList = json['images'] as List?;
    
    return ServiceModel(
      id: json['id'] ?? '',
      providerId: json['providerId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      experience: json['experience'],
      availability: json['availability'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      viewsCount: json['viewsCount'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      images: imageList?.map((e) => e['url'] as String).toList() ?? [],
      providerName: provider != null ? '${provider['firstName']} ${provider['lastName']}' : null,
      providerPhone: provider?['phone'],
      providerPhoto: provider?['profilePhoto'],
      category: json['category'] != null ? ServiceCategoryModel.fromJson(json['category']) : null,
    );
  }
}
