class TechnicianModel {
  final int id;
  final String name;
  final String avatar;
  final int orderCount;
  final bool isHot;

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.orderCount,
    required this.isHot,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? json['headUrl'] ?? '',
      orderCount: json['orderCount'] ?? json['orders'] ?? 0,
      isHot: json['isRecommend'] == true || json['isHot'] == true || json['recommend'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'orderCount': orderCount,
        'isHot': isHot,
      };
}