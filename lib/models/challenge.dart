import 'package:intl/intl.dart';

enum ChallengeType {
  daily,    // 每日挑战
  weekly,   // 每周挑战
  special,  // 特殊活动
}

enum ChallengeCategory {
  steps,
  distance,
  calories,
  time,
  achievement,
}

// 挑战任务模型
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeCategory category;
  final int targetValue;
  int currentValue;
  final int expReward;
  final DateTime startDate;
  final DateTime endDate;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.category = ChallengeCategory.steps,
    required this.targetValue,
    this.currentValue = 0,
    this.expReward = 50,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isActive => DateTime.now().isAfter(startDate) && 
                       DateTime.now().isBefore(endDate);

  String get timeRemaining {
    if (isExpired) return '已过期';
    final diff = endDate.difference(DateTime.now());
    if (diff.inHours < 24) return '剩余${diff.inHours}小时';
    return '剩余${diff.inDays}天';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'category': category.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'expReward': expReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChallengeType.daily,
      ),
      category: ChallengeCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ChallengeCategory.steps,
      ),
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      expReward: json['expReward'] as int? ?? 50,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

// 挑战任务生成器
class ChallengeGenerator {
  // 生成今日挑战
  static List<Challenge> generateDailyChallenges() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return [
      Challenge(
        id: 'daily_steps_${DateFormat('yyyyMMdd').format(now)}',
        title: '每日目标',
        description: '完成今日步数目标',
        type: ChallengeType.daily,
        targetValue: 10000,
        expReward: 50,
        startDate: startOfDay,
        endDate: endOfDay,
      ),
      Challenge(
        id: 'daily_distance_${DateFormat('yyyyMMdd').format(now)}',
        title: '距离挑战',
        description: '今日步行5公里',
        type: ChallengeType.daily,
        category: ChallengeCategory.distance,
        targetValue: 5000, // 5km in meters
        expReward: 30,
        startDate: startOfDay,
        endDate: endOfDay,
      ),
      Challenge(
        id: 'daily_calories_${DateFormat('yyyyMMdd').format(now)}',
        title: '燃烧卡路里',
        description: '今日消耗300千卡',
        type: ChallengeType.daily,
        category: ChallengeCategory.calories,
        targetValue: 300,
        expReward: 40,
        startDate: startOfDay,
        endDate: endOfDay,
      ),
    ];
  }

  // 生成本周挑战
  static List<Challenge> generateWeeklyChallenges() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
    
    return [
      Challenge(
        id: 'weekly_steps_${DateFormat('yyyyMMdd').format(startOfWeekDay)}',
        title: '周度目标',
        description: '本周累计70,000步',
        type: ChallengeType.weekly,
        targetValue: 70000,
        expReward: 200,
        startDate: startOfWeekDay,
        endDate: endOfWeek,
      ),
      Challenge(
        id: 'weekly_streak_${DateFormat('yyyyMMdd').format(startOfWeekDay)}',
        title: '完美一周',
        description: '连续7天达成目标',
        type: ChallengeType.weekly,
        targetValue: 7,
        expReward: 300,
        startDate: startOfWeekDay,
        endDate: endOfWeek,
      ),
    ];
  }
}
