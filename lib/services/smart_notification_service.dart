import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../step_counter_service.dart';

/// 通知类型
enum NotificationType {
  morningMotivation,    // 晨间激励
  streakReminder,       // 连续打卡提醒
  dailySummary,         // 日终总结
  goalReminder,         // 目标提醒
  achievementUnlock,    // 成就解锁
}

/// 智能通知服务
class SmartNotificationService {
  static final SmartNotificationService _instance = SmartNotificationService._();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 通知开关状态
  bool _morningEnabled = true;
  bool _streakEnabled = true;
  bool _dailySummaryEnabled = true;
  bool _goalEnabled = true;

  // 配置键
  static const String _keyMorningEnabled = 'notification_morning';
  static const String _keyStreakEnabled = 'notification_streak';
  static const String _keyDailySummaryEnabled = 'notification_daily_summary';
  static const String _keyGoalEnabled = 'notification_goal';

  /// 初始化通知服务
  Future<void> initialize() async {
    // 加载保存的设置
    await _loadSettings();

    // Android通知图标设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // 请求权限
    await _requestPermissions();

    // 调度定时通知
    await _scheduleNotifications();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _morningEnabled = prefs.getBool(_keyMorningEnabled) ?? true;
    _streakEnabled = prefs.getBool(_keyStreakEnabled) ?? true;
    _dailySummaryEnabled = prefs.getBool(_keyDailySummaryEnabled) ?? true;
    _goalEnabled = prefs.getBool(_keyGoalEnabled) ?? true;
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMorningEnabled, _morningEnabled);
    await prefs.setBool(_keyStreakEnabled, _streakEnabled);
    await prefs.setBool(_keyDailySummaryEnabled, _dailySummaryEnabled);
    await prefs.setBool(_keyGoalEnabled, _goalEnabled);
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 调度定时通知
  Future<void> _scheduleNotifications() async {
    // 取消所有已存在的通知
    await _notifications.cancelAll();

    // 晨间激励通知 (每天早上8点)
    if (_morningEnabled) {
      await _showDailyNotification(
        id: NotificationType.morningMotivation.index,
        hour: 8,
        minute: 0,
        title: '🌅 新的一天开始啦！',
        body: '今天的目标是10000步，向着健康出发！',
      );
    }

    // 连续打卡提醒 (每天中午12点)
    if (_streakEnabled) {
      await _showDailyNotification(
        id: NotificationType.streakReminder.index,
        hour: 12,
        minute: 0,
        title: '⏰ 中午提醒',
        body: '别忘了今天的步数目标哦，坚持就是胜利！',
      );
    }

    // 日终总结 (每天晚上8点)
    if (_dailySummaryEnabled) {
      await _showDailyNotification(
        id: NotificationType.dailySummary.index,
        hour: 20,
        minute: 0,
        title: '📊 今日步数总结',
        body: '点击查看今天的运动数据报告',
      );
    }
  }

  /// 显示每日定时通知
  Future<void> _showDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Android通知设置
    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 立即显示通知（用于测试）
    await _notifications.show(id, title, body, details);
  }

  /// 显示目标完成通知
  Future<void> showGoalCompletedNotification(int steps, int goal) async {
    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      NotificationType.goalReminder.index,
      '🎉 目标达成！',
      '恭喜你今天走了 $steps 步，已完成目标！',
      details,
    );
  }

  /// 显示成就解锁通知
  Future<void> showAchievementUnlockedNotification(
      String achievementName, String description) async {
    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      NotificationType.achievementUnlock.index,
      '🏆 成就解锁！',
      '$achievementName: $description',
      details,
    );
  }

  /// 发送上下文感知的智能提醒
  Future<void> sendSmartReminder({
    required int currentSteps,
    required int goal,
    required int streakDays,
  }) async {
    if (!_goalEnabled) return;

    // 如果目标已完成，不再发送目标提醒
    if (currentSteps >= goal) return;

    // 计算剩余步数
    final remaining = goal - currentSteps;

    // 根据进度发送不同类型的提醒
    if (remaining > goal * 0.8) {
      // 刚开始，发送鼓励通知
      await _showEncouragementNotification(remaining);
    } else if (remaining > goal * 0.5) {
      // 中等进度，发送进度通知
      await _showProgressNotification(currentSteps, goal);
    } else if (remaining > goal * 0.2) {
      // 快完成了，发送冲刺通知
      await _showSprintNotification(remaining);
    }
  }

  Future<void> _showEncouragementNotification(int remaining) async {
    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      100,
      '💪 开始行动！',
      '还剩 ${remaining} 步就能达成今日目标，加油！',
      details,
    );
  }

  Future<void> _showProgressNotification(int current, int goal) async {
    final progress = (current / goal * 100).round();

    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      101,
      '📈 进度更新',
      '你已经完成了 $progress%，继续努力！',
      details,
    );
  }

  Future<void> _showSprintNotification(int remaining) async {
    const androidDetails = AndroidNotificationDetails(
      'stepcounter_channel',
      '步数统计通知',
      channelDescription: '用于提醒和激励的通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      102,
      '🏃 冲刺时刻！',
      '只差 ${remaining} 步就完成目标了，冲鸭！',
      details,
    );
  }

  /// 设置通知开关
  Future<void> setNotificationEnabled(NotificationType type, bool enabled) async {
    switch (type) {
      case NotificationType.morningMotivation:
        _morningEnabled = enabled;
        break;
      case NotificationType.streakReminder:
        _streakEnabled = enabled;
        break;
      case NotificationType.dailySummary:
        _dailySummaryEnabled = enabled;
        break;
      case NotificationType.goalReminder:
        _goalEnabled = enabled;
        break;
      default:
        return;
    }

    await _saveSettings();
    await _scheduleNotifications();
  }

  /// 获取通知开关状态
  bool isEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.morningMotivation:
        return _morningEnabled;
      case NotificationType.streakReminder:
        return _streakEnabled;
      case NotificationType.dailySummary:
        return _dailySummaryEnabled;
      case NotificationType.goalReminder:
        return _goalEnabled;
      default:
        return true;
    }
  }

  /// 获取所有通知设置
  Map<NotificationType, bool> getAllSettings() {
    return {
      NotificationType.morningMotivation: _morningEnabled,
      NotificationType.streakReminder: _streakEnabled,
      NotificationType.dailySummary: _dailySummaryEnabled,
      NotificationType.goalReminder: _goalEnabled,
    };
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
