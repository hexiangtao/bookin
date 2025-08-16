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
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString() ?? json['link']?.toString(),
      linkType: json['linkType']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == 'true' || json['status'] == 1 || json['status'] == '1',
      sort: int.tryParse(json['sort'].toString()) ?? 0,
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