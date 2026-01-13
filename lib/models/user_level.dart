// 用户等级系统模型
class UserLevel {
  final int level;
  final int currentExp;
  final int expToNextLevel;
  final String title;
  final String iconName;

  UserLevel({
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
    required this.title,
    required this.iconName,
  });

  double get progress => currentExp / expToNextLevel;

  // 根据经验值计算等级
  static UserLevel fromExp(int totalExp) {
    int level = 1;
    int remainingExp = totalExp;
    
    while (remainingExp >= _getExpRequiredForLevel(level)) {
      remainingExp -= _getExpRequiredForLevel(level);
      level++;
    }

    return UserLevel(
      level: level,
      currentExp: remainingExp,
      expToNextLevel: _getExpRequiredForLevel(level),
      title: _getTitleForLevel(level),
      iconName: _getIconForLevel(level),
    );
  }

  // 计算升到下一级所需经验值（递增式）
  static int _getExpRequiredForLevel(int level) {
    return 100 + (level - 1) * 50; // 1级需100, 2级需150, 3级需200...
  }

  // 根据等级返回称号
  static String _getTitleForLevel(int level) {
    if (level >= 50) return '步行大师';
    if (level >= 40) return '运动专家';
    if (level >= 30) return '健康达人';
    if (level >= 20) return '活力使者';
    if (level >= 10) return '坚持者';
    if (level >= 5) return '行者';
    return '新手';
  }

  // 根据等级返回图标名称
  static String _getIconForLevel(int level) {
    if (level >= 50) return 'military_tech';
    if (level >= 40) return 'emoji_events';
    if (level >= 30) return 'stars';
    if (level >= 20) return 'local_fire_department';
    if (level >= 10) return 'trending_up';
    if (level >= 5) return 'favorite';
    return 'catching_pokemon';
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentExp': currentExp,
      'expToNextLevel': expToNextLevel,
      'title': title,
      'iconName': iconName,
    };
  }

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'] as int,
      currentExp: json['currentExp'] as int,
      expToNextLevel: json['expToNextLevel'] as int,
      title: json['title'] as String,
      iconName: json['iconName'] as String,
    );
  }
}
