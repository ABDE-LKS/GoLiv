class JobCategoryModel {
  final String id;
  final String name;
  final String? icon;

  JobCategoryModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

class JobModel {
  final String id;
  final String employerId;
  final String categoryId;
  final String companyName;
  final String? logo;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String? salary;
  final String employmentType;
  final String? workingHours;
  final String status;
  final int viewsCount;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWhatsapp;
  final DateTime createdAt;
  
  final String? employerName;
  final String? employerPhoto;
  final JobCategoryModel? category;

  JobModel({
    required this.id,
    required this.employerId,
    required this.categoryId,
    required this.companyName,
    this.logo,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    this.salary,
    required this.employmentType,
    this.workingHours,
    required this.status,
    required this.viewsCount,
    this.contactEmail,
    this.contactPhone,
    this.contactWhatsapp,
    required this.createdAt,
    this.employerName,
    this.employerPhoto,
    this.category,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final employer = json['employer'];
    
    return JobModel(
      id: json['id'] ?? '',
      employerId: json['employerId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      companyName: json['companyName'] ?? '',
      logo: json['logo'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'],
      employmentType: json['employmentType'] ?? 'FULL_TIME',
      workingHours: json['workingHours'],
      status: json['status'] ?? 'ACTIVE',
      viewsCount: json['viewsCount'] ?? 0,
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      contactWhatsapp: json['contactWhatsapp'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      employerName: employer != null ? '${employer['firstName']} ${employer['lastName']}' : null,
      employerPhoto: employer?['profilePhoto'],
      category: json['category'] != null ? JobCategoryModel.fromJson(json['category']) : null,
    );
  }
}
