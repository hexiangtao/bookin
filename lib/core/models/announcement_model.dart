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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      linkUrl: json['link_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      expiredAt: json['expired_at'] != null ? DateTime.tryParse(json['expired_at']) : null,
      isActive: json['is_active'] ?? false,
      priority: json['priority'] ?? 0,
      type: json['type'] ?? 'text',
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