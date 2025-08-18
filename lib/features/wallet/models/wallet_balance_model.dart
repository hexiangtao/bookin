class WalletBalanceModel {
  final double balance;
  final int level;
  final String levelName;
  final String levelIcon;
  final double nextLevelAmount;
  final String currency;

  WalletBalanceModel({
    required this.balance,
    required this.level,
    required this.levelName,
    required this.levelIcon,
    required this.nextLevelAmount,
    this.currency = 'CNY',
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: (json['balance'] ?? 0).toDouble(),
      level: json['level'] ?? 0,
      levelName: json['levelName'] ?? '',
      levelIcon: json['levelIcon'] ?? '',
      nextLevelAmount: (json['nextLevelAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'CNY',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'level': level,
      'levelName': levelName,
      'levelIcon': levelIcon,
      'nextLevelAmount': nextLevelAmount,
      'currency': currency,
    };
  }

  String get formattedBalance {
    return '¥${balance.toStringAsFixed(2)}';
  }

  String get levelClass {
    if (levelName.toLowerCase().contains('金') || levelName.toLowerCase().contains('gold')) {
      return 'gold';
    } else if (levelName.toLowerCase().contains('铂') || levelName.toLowerCase().contains('platinum')) {
      return 'platinum';
    } else if (levelName.toLowerCase().contains('钻') || levelName.toLowerCase().contains('diamond')) {
      return 'diamond';
    }
    
    if (level >= 3) {
      return 'diamond';
    } else if (level >= 2) {
      return 'platinum';
    } else if (level >= 1) {
      return 'gold';
    }
    
    return 'default';
  }

  WalletBalanceModel copyWith({
    double? balance,
    int? level,
    String? levelName,
    String? levelIcon,
    double? nextLevelAmount,
    String? currency,
  }) {
    return WalletBalanceModel(
      balance: balance ?? this.balance,
      level: level ?? this.level,
      levelName: levelName ?? this.levelName,
      levelIcon: levelIcon ?? this.levelIcon,
      nextLevelAmount: nextLevelAmount ?? this.nextLevelAmount,
      currency: currency ?? this.currency,
    );
  }
}