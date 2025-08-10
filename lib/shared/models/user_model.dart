class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final String? email;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        avatar: json['avatar'] as String?,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'avatar': avatar,
        'email': email,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
    );
  }
}