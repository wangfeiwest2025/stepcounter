// 成就勋章数据模型
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementCategory category;
  final int requiredValue;
  final int expReward;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.requiredValue,
    this.expReward = 100,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'category': category.toString(),
      'requiredValue': requiredValue,
      'expReward': expReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => AchievementCategory.steps,
      ),
      requiredValue: json['requiredValue'] as int,
      expReward: json['expReward'] as int? ?? 100,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

enum AchievementCategory {
  steps,      // 步数相关
  distance,   // 距离相关
  streak,     // 连续打卡
  challenge,  // 挑战任务
  special,    // 特殊成就
}
