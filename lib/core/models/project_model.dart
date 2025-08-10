class ProjectModel {
  final int id;
  final String name;
  final String cover;
  final int orderCount;
  final int price; // 分
  final int? originalPrice; // 分
  final int duration; // 分钟

  const ProjectModel({
    required this.id,
    required this.name,
    required this.cover,
    required this.orderCount,
    required this.price,
    this.originalPrice,
    required this.duration,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      cover: json['icon'] ?? json['image'] ?? '',
      orderCount: json['orderCount'] ?? 0,
      price: json['price'] ?? 0,
      originalPrice: json['originalPrice'],
      duration: json['timer'] ?? json['duration'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cover': cover,
        'price': price,
        'originalPrice': originalPrice,
        'duration': duration,
      };

  String get priceYuan => (price / 100).toStringAsFixed(2);
  String? get originalPriceYuan =>
      originalPrice != null ? (originalPrice! / 100).toStringAsFixed(2) : null;
  
  // 为了兼容UI中使用的imageUrl属性
  String get imageUrl => cover;
}