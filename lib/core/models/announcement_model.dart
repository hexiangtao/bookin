class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? linkUrl;
  final DateTime createdAt;
  final DateTime? expiredAt;
  final bool isActive;
  final int priority;
  final String type; // 'popup', 'banner', 'text'

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.linkUrl,
    required this.createdAt,
    this.expiredAt,
    required this.isActive,
    required this.priority,
    required this.type,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      linkUrl: json['link_url']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      expiredAt: json['expired_at'] != null ? DateTime.tryParse(json['expired_at'].toString()) : null,
      isActive: json['is_active'] == true || json['is_active'] == 'true' || json['is_active'] == 1,
      priority: int.tryParse(json['priority'].toString()) ?? 0,
      type: json['type']?.toString() ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'created_at': createdAt.toIso8601String(),
      'expired_at': expiredAt?.toIso8601String(),
      'is_active': isActive,
      'priority': priority,
      'type': type,
    };
  }

  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt!);
  }

  bool get isValid {
    return isActive && !isExpired;
  }
}