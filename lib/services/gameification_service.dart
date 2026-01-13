import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../models/user_level.dart';
import '../models/challenge.dart';

class GameificationService {
  static final GameificationService _instance = GameificationService._internal();
  factory GameificationService() => _instance;
  GameificationService._internal() {
    _initialize();
  }

  // 经验值和等级
  int _totalExp = 0;
  UserLevel? _userLevel;
  
  // 成就系统
  List<Achievement> _achievements = [];
  
  // 挑战系统
  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  
  // Streams
  final StreamController<UserLevel> _levelStreamController = 
      StreamController<UserLevel>.broadcast();
  final StreamController<Achievement> _achievementUnlockedController = 
      StreamController<Achievement>.broadcast();
  final StreamController<List<Challenge>> _challengeUpdateController = 
      StreamController<List<Challenge>>.broadcast();

  Stream<UserLevel> get levelStream => _levelStreamController.stream;
  Stream<Achievement> get achievementUnlockedStream => _achievementUnlockedController.stream;
  Stream<List<Challenge>> get challengeUpdateStream => _challengeUpdateController.stream;

  UserLevel? get userLevel => _userLevel;
  List<Achievement> get achievements => _achievements;
  List<Challenge> get activeChallenges => [..._dailyChallenges, ..._weeklyChallenges]
      .where((c) => c.isActive && !c.isCompleted).toList();
  List<Challenge> get completedChallenges => [..._dailyChallenges, ..._weeklyChallenges]
      .where((c) => c.isCompleted).toList();

  Future<void> _initialize() async {
    await _loadData();
    await _initializeAchievements();
    await _updateDailyChallenges();
    await _updateWeeklyChallenges();
  }

  // ==================== 经验值和等级系统 ====================
  
  Future<void> addExp(int exp, {String? reason}) async {
    _totalExp += exp;
    _userLevel = UserLevel.fromExp(_totalExp);
    _levelStreamController.sink.add(_userLevel!);
    await _saveData();
    
    print('获得经验值: +$exp ${reason != null ? "($reason)" : ""}');
  }

  // ==================== 成就系统 ====================
  
  Future<void> _initializeAchievements() async {
    if (_achievements.isEmpty) {
      _achievements = _getDefaultAchievements();
    }
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      // 步数成就
      Achievement(
        id: 'first_step',
        title: '启程',
        description: '完成第一步',
        iconName: 'play_arrow',
        category: AchievementCategory.steps,
        requiredValue: 1,
        expReward: 10,
      ),
      Achievement(
        id: 'steps_1k',
        title: '千里之行',
        description: '单日步数达到1,000步',
        iconName: 'directions_walk',
        category: AchievementCategory.steps,
        requiredValue: 1000,
        expReward: 50,
      ),
      Achievement(
        id: 'steps_5k',
        title: '健步如飞',
        description: '单日步数达到5,000步',
        iconName: 'trending_up',
        category: AchievementCategory.steps,
        requiredValue: 5000,
        expReward: 100,
      ),
      Achievement(
        id: 'steps_10k',
        title: '步行达人',
        description: '单日步数达到10,000步',
        iconName: 'emoji_events',
        category: AchievementCategory.steps,
        requiredValue: 10000,
        expReward: 200,
      ),
      Achievement(
        id: 'steps_20k',
        title: '超级战士',
        description: '单日步数达到20,000步',
        iconName: 'military_tech',
        category: AchievementCategory.steps,
        requiredValue: 20000,
        expReward: 500,
      ),
      
      // 距离成就
      Achievement(
        id: 'distance_5km',
        title: '初级旅行者',
        description: '单日步行5公里',
        iconName: 'map',
        category: AchievementCategory.distance,
        requiredValue: 5000,
        expReward: 100,
      ),
      Achievement(
        id: 'distance_10km',
        title: '长途跋涉',
        description: '单日步行10公里',
        iconName: 'explore',
        category: AchievementCategory.distance,
        requiredValue: 10000,
        expReward: 300,
      ),
      
      // 连续打卡成就
      Achievement(
        id: 'streak_3',
        title: '坚持三天',
        description: '连续3天达成目标',
        iconName: 'local_fire_department',
        category: AchievementCategory.streak,
        requiredValue: 3,
        expReward: 150,
      ),
      Achievement(
        id: 'streak_7',
        title: '完美一周',
        description: '连续7天达成目标',
        iconName: 'whatshot',
        category: AchievementCategory.streak,
        requiredValue: 7,
        expReward: 300,
      ),
      Achievement(
        id: 'streak_30',
        title: '月度冠军',
        description: '连续30天达成目标',
        iconName: 'stars',
        category: AchievementCategory.streak,
        requiredValue: 30,
        expReward: 1000,
      ),
      
      // 特殊成就
      Achievement(
        id: 'early_bird',
        title: '早起的鸟儿',
        description: '在早上6点前完成5000步',
        iconName: 'wb_sunny',
        category: AchievementCategory.special,
        requiredValue: 1,
        expReward: 200,
      ),
      Achievement(
        id: 'night_owl',
        title: '夜行者',
        description: '在晚上10点后完成运动',
        iconName: 'nights_stay',
        category: AchievementCategory.special,
        requiredValue: 1,
        expReward: 150,
      ),
    ];
  }

  Future<void> checkStepAchievements(int steps) async {
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked && 
          achievement.category == AchievementCategory.steps &&
          steps >= achievement.requiredValue) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> checkDistanceAchievements(double distanceInMeters) async {
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked && 
          achievement.category == AchievementCategory.distance &&
          distanceInMeters >= achievement.requiredValue) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> checkStreakAchievements(int streakDays) async {
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked && 
          achievement.category == AchievementCategory.streak &&
          streakDays >= achievement.requiredValue) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      
      // 添加经验值奖励
      await addExp(achievement.expReward, reason: '解锁成就: ${achievement.title}');
      
      // 通知UI
      _achievementUnlockedController.sink.add(achievement);
      
      await _saveData();
      print('🏆 解锁成就: ${achievement.title}');
    }
  }

  int get unlockedAchievementsCount => 
      _achievements.where((a) => a.isUnlocked).length;
  
  int get totalAchievementsCount => _achievements.length;

  // ==================== 挑战系统 ====================
  
  Future<void> _updateDailyChallenges() async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    
    // 如果没有今日挑战,生成新的
    if (_dailyChallenges.isEmpty || 
        !_dailyChallenges.first.id.contains(today)) {
      _dailyChallenges = ChallengeGenerator.generateDailyChallenges();
      await _saveData();
    }
  }

  Future<void> _updateWeeklyChallenges() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final weekId = DateFormat('yyyyMMdd').format(startOfWeek);
    
    // 如果没有本周挑战,生成新的
    if (_weeklyChallenges.isEmpty || 
        !_weeklyChallenges.first.id.contains(weekId)) {
      _weeklyChallenges = ChallengeGenerator.generateWeeklyChallenges();
      await _saveData();
    }
  }

  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final allChallenges = [..._dailyChallenges, ..._weeklyChallenges];
    final challenge = allChallenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => throw Exception('Challenge not found'),
    );
    
    challenge.currentValue = progress;
    
    if (challenge.currentValue >= challenge.targetValue && !challenge.isCompleted) {
      challenge.isCompleted = true;
      await addExp(challenge.expReward, reason: '完成挑战: ${challenge.title}');
      print('✅ 完成挑战: ${challenge.title}');
    }
    
    _challengeUpdateController.sink.add(activeChallenges);
    await _saveData();
  }

  Future<void> checkChallengesForSteps(int steps, double distanceInMeters, double calories) async {
    // 更新每日挑战
    await _updateDailyChallenges();
    await _updateWeeklyChallenges();
    
    for (var challenge in _dailyChallenges) {
      if (challenge.id.contains('steps')) {
        await updateChallengeProgress(challenge.id, steps);
      } else if (challenge.id.contains('distance')) {
        await updateChallengeProgress(challenge.id, distanceInMeters.toInt());
      } else if (challenge.id.contains('calories')) {
        await updateChallengeProgress(challenge.id, calories.toInt());
      }
    }
  }

  // ==================== 数据持久化 ====================
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载经验值
    _totalExp = prefs.getInt('total_exp') ?? 0;
    _userLevel = UserLevel.fromExp(_totalExp);
    
    // 加载成就
    final achievementsJson = prefs.getString('achievements');
    if (achievementsJson != null) {
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      _achievements = decoded.map((json) => Achievement.fromJson(json)).toList();
    }
    
    // 加载每日挑战
    final dailyChallengesJson = prefs.getString('daily_challenges');
    if (dailyChallengesJson != null) {
      final List<dynamic> decoded = jsonDecode(dailyChallengesJson);
      _dailyChallenges = decoded.map((json) => Challenge.fromJson(json)).toList();
    }
    
    // 加载每周挑战
    final weeklyChallengesJson = prefs.getString('weekly_challenges');
    if (weeklyChallengesJson != null) {
      final List<dynamic> decoded = jsonDecode(weeklyChallengesJson);
      _weeklyChallenges = decoded.map((json) => Challenge.fromJson(json)).toList();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 保存经验值
    await prefs.setInt('total_exp', _totalExp);
    
    // 保存成就
    final achievementsJson = jsonEncode(
      _achievements.map((a) => a.toJson()).toList(),
    );
    await prefs.setString('achievements', achievementsJson);
    
    // 保存每日挑战
    final dailyChallengesJson = jsonEncode(
      _dailyChallenges.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('daily_challenges', dailyChallengesJson);
    
    // 保存每周挑战
    final weeklyChallengesJson = jsonEncode(
      _weeklyChallenges.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('weekly_challenges', weeklyChallengesJson);
  }

  void dispose() {
    _levelStreamController.close();
    _achievementUnlockedController.close();
    _challengeUpdateController.close();
  }
}
