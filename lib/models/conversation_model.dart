class ConversationModel {
  final String id;
  final String adId;
  final String? adTitle;
  final String? adImage;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePhoto;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.adId,
    this.adTitle,
    this.adImage,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePhoto,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final bool isBuyer = json['buyerId'] == currentUserId;
    final otherUser = isBuyer ? json['seller'] : json['buyer'];
    
    return ConversationModel(
      id: json['id'],
      adId: json['adId'],
      adTitle: json['ad']?['title'],
      adImage: (json['ad']?['images'] as List?)?.isNotEmpty == true ? json['ad']['images'][0]['url'] : null,
      otherUserId: otherUser?['id'] ?? '',
      otherUserName: otherUser != null ? '${otherUser['firstName']} ${otherUser['lastName']}' : 'مستخدم',
      otherUserProfilePhoto: otherUser?['profilePhoto'],
      lastMessage: json['messages'] != null && (json['messages'] as List).isNotEmpty 
          ? json['messages'].first['text'] 
          : 'لا توجد رسائل بعد',
      updatedAt: DateTime.parse(json['updatedAt']),
      unreadCount: json['_count']?['messages'] ?? 0, // Assuming backend provides this or calculate
    );
  }
}

class ChatMessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;
  final bool isRead;
  final String? image;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.isRead = false,
    this.image,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['text'] ?? '',
      senderId: json['senderId'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      image: json['image'],
    );
  }

  ChatMessageModel copyWith({bool? isRead}) {
    return ChatMessageModel(
      id: id,
      content: content,
      senderId: senderId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      image: image,
    );
  }
}
