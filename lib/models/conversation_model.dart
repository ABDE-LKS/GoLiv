class ConversationModel {
  final String id;
  final String adId;
  final String? adTitle;
  final String? adImage;
  final String otherUserName;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isRead;

  ConversationModel({
    required this.id,
    required this.adId,
    this.adTitle,
    this.adImage,
    required this.otherUserName,
    required this.lastMessage,
    required this.updatedAt,
    this.isRead = true,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    String? otherName;
    if (json['buyerId'] != null && json['buyer'] != null) {
      otherName = '${json['buyer']['firstName']} ${json['buyer']['lastName']}';
    } else if (json['seller'] != null) {
      otherName = '${json['seller']['firstName']} ${json['seller']['lastName']}';
    }

    return ConversationModel(
      id: json['id'],
      adId: json['adId'],
      adTitle: json['ad']?['title'],
      adImage: (json['ad']?['images'] as List?)?.isNotEmpty == true ? json['ad']['images'][0]['url'] : null,
      otherUserName: otherName ?? 'مستخدم',
      lastMessage: json['messages'] != null && (json['messages'] as List).isNotEmpty 
          ? json['messages'].first['text'] 
          : 'لا توجد رسائل بعد',
      updatedAt: DateTime.parse(json['updatedAt']),
      isRead: true, // Simplified
    );
  }
}

class ChatMessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['text'] ?? '',
      senderId: json['senderId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
