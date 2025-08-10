class BannerModel {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? linkType; // 'page', 'url', 'none'
  final bool isActive;
  final int sort;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.linkType,
    this.isActive = true,
    this.sort = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      linkUrl: json['linkUrl'] ?? json['link'],
      linkType: json['linkType'],
      isActive: json['isActive'] ?? json['status'] == 1,
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'linkType': linkType,
      'isActive': isActive,
      'sort': sort,
    };
  }
}