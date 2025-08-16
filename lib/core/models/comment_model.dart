class CommentModel {
  final int id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String content;
  final String createTime;
  final String serviceType;
  final List<String> images;

  const CommentModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.content,
    required this.createTime,
    required this.serviceType,
    this.images = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userName: json['userName']?.toString() ?? json['nickname']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? json['avatar']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? json['score']?.toString() ?? '5.0') ?? 5.0,
      content: json['content']?.toString() ?? json['comment']?.toString() ?? '',
      createTime: json['createTime']?.toString() ?? json['time']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? json['service']?.toString() ?? '',
      images: json['images'] != null ? List<String>.from(json['images'].map((e) => e.toString())) : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'content': content,
        'createTime': createTime,
        'serviceType': serviceType,
        'images': images,
      };
}