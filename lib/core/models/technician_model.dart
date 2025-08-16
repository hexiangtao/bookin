class TechnicianModel {
  final int id;
  final String name;
  final String avatar;
  final int orderCount;
  final bool isHot;
  final bool isVerified;
  final bool isRecommend;
  final String? shopName;
  final String? merchantName;
  final int commentCount;
  final int likeCount;
  final List<String> tags;
  final double? distance;
  final int status; // 0: 可预约, 1: 忙碌, 2: 休息
  final double? rating;
  final String? description;
  final double? goodRate;
  final int avatarShape; // 0: 圆形, 1: 方形
  final String? earliestTime;
  final List<String> photos; // 技师照片列表

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.orderCount,
    required this.isHot,
    this.isVerified = false,
    this.isRecommend = false,
    this.shopName,
    this.merchantName,
    this.commentCount = 0,
    this.likeCount = 0,
    this.tags = const [],
    this.distance,
    this.status = 0,
    this.rating,
    this.description,
    this.goodRate,
    this.avatarShape = 1,
    this.earliestTime,
    this.photos = const [],
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? json['headUrl']?.toString() ?? '',
      orderCount: int.tryParse(json['orderCount']?.toString() ?? json['orders']?.toString() ?? '0') ?? 0,
      isHot: json['isRecommend'] == true || json['isRecommend'] == 'true' || json['isHot'] == true || json['isHot'] == 'true' || json['recommend'] == 1 || json['recommend'] == '1',
      isVerified: json['isVerified'] == true || json['isVerified'] == 'true',
      isRecommend: json['isRecommend'] == true || json['isRecommend'] == 'true',
      shopName: json['shopName']?.toString(),
      merchantName: json['merchantName']?.toString() ?? json['shopName']?.toString(),
      commentCount: int.tryParse(json['commentCount'].toString()) ?? 0,
      likeCount: int.tryParse(json['likeCount'].toString()) ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags'].map((e) => e.toString())) : [],
      distance: double.tryParse(json['distance']?.toString() ?? ''),
      status: int.tryParse(json['status'].toString()) ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      description: json['description']?.toString(),
      goodRate: double.tryParse(json['goodRate']?.toString() ?? ''),
      avatarShape: int.tryParse(json['avatarShape'].toString()) ?? 1,
      earliestTime: json['earliestTime']?.toString(),
      photos: json['photos'] != null ? List<String>.from(json['photos'].map((e) => e.toString())) : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'orderCount': orderCount,
        'isHot': isHot,
        'isVerified': isVerified,
        'isRecommend': isRecommend,
        'shopName': shopName,
        'merchantName': merchantName,
        'commentCount': commentCount,
        'likeCount': likeCount,
        'tags': tags,
        'distance': distance,
        'status': status,
        'rating': rating,
        'description': description,
        'goodRate': goodRate,
        'avatarShape': avatarShape,
        'earliestTime': earliestTime,
        'photos': photos,
      };
}