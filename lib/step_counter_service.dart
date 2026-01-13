import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterService {
  // Singleton pattern
  static final StepCounterService _instance = StepCounterService._internal();
  factory StepCounterService() => _instance;
  StepCounterService._internal() {
    _initialize();
  }

  int _todaySteps = 0;
  String _todayDate = '';
  final Map<String, int> _dailySteps = {};

  final StreamController<int> _stepStreamController =
      StreamController<int>.broadcast();
  final StreamController<String> _statusStreamController =
      StreamController<String>.broadcast();

  Stream<int> get stepStream => _stepStreamController.stream;
  Stream<String> get statusStream => _statusStreamController.stream;
  int get todaySteps => _todaySteps;

  // Calculate calories burned (average: 0.04 calories per step, adjusted by mass if available)
  // Higher weight burns more calories. Base: 70kg -> 0.04 kcal/step
  Future<double> getCaloriesBurned() async {
    final weight = await getUserWeight();
    final factor = 0.04 * (weight / 70.0);
    return _todaySteps * factor;
  }

  // Calculate distance in kilometers (average: 0.7 meters per step, adjusted by height if available)
  // Taller person has longer stride. Base: 175cm -> 0.7m stride
  Future<double> getDistanceInKm() async {
    final height = await getUserHeight();
    final stride = 0.7 * (height / 175.0);
    return (_todaySteps * stride) / 1000;
  }

  // Legacy getters (backward compatibility or defaults)
  double get caloriesBurned => _todaySteps * 0.04;
  double get distanceInKm => (_todaySteps * 0.7) / 1000;

  Future<bool> checkActivityPermission() async {
    var activityStatus = await Permission.activityRecognition.status;
    return activityStatus.isGranted;
  }

  Future<bool> requestActivityPermission() async {
    var activityStatus = await Permission.activityRecognition.status;
    if (activityStatus.isDenied) {
      activityStatus = await Permission.activityRecognition.request();
    }
    var notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }
    return activityStatus.isGranted;
  }

  void _initialize() async {
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _loadStoredData();
    _listenToBackgroundService();
  }

  DateTime? _lastUpdateTime;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  void _listenToBackgroundService() {
    FlutterBackgroundService().on('update').listen((event) {
      if (event != null) {
        if (event.containsKey('heartbeat')) {
          print('StepCounterService: Service Heartbeat - ${event['heartbeat']}');
        }

        if (event.containsKey('steps')) {
          final int steps = event['steps'] as int;
          final String date = event['date'] as String;
          _todaySteps = steps;
          if (date != _todayDate) {
            _todayDate = date;
            _loadStoredData();
          }
          _dailySteps[_todayDate] = _todaySteps;
          _stepStreamController.sink.add(_todaySteps);
          _updateTotalSteps(steps);
        }

        if (event.containsKey('lastUpdate')) {
           _lastUpdateTime = DateTime.parse(event['lastUpdate'] as String);
        }

        if (event.containsKey('status')) {
          final String status = event['status'] as String;
          print('StepCounterService: Status Change - $status');
          _statusStreamController.sink.add(status);
        }
      }
    });
  }

  void synchronize() {
    print('StepCounterService: Synchronization Requested');
    FlutterBackgroundService().invoke('getData');
    FlutterBackgroundService().invoke('startStepCounting');
  }

  Future<void> _updateTotalSteps(int todaySteps) async {
    final prefs = await SharedPreferences.getInstance();
    // We update total steps by summing all known daily steps + today
    int total = 0;
    _dailySteps.forEach((key, value) {
      if (key != _todayDate) total += value;
    });
    total += todaySteps;
    await prefs.setInt('total_steps_all_time', total);
  }

  Future<int> getTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_steps_all_time') ?? 0;
  }

  void activateService() {
    FlutterBackgroundService().invoke('startStepCounting');
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todaySteps = prefs.getInt('steps_today_$_todayDate') ?? 0;
    _dailySteps.clear();
    final trackedDays = prefs.getStringList('tracked_days') ?? [];
    for (String day in trackedDays) {
      _dailySteps[day] = prefs.getInt('steps_today_$day') ?? 0;
    }
    _stepStreamController.sink.add(_todaySteps);
  }

  Map<String, int> getRecentDaysSteps(int days) {
    final Map<String, int> recentSteps = {};
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      recentSteps[date] = _dailySteps[date] ?? (date == _todayDate ? _todaySteps : 0);
    }
    return Map.fromEntries(recentSteps.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_step_goal', goal);
  }

  Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_step_goal') ?? 10000;
  }

  Future<double> getGoalCompletion() async {
    final goal = await getDailyGoal();
    if (goal <= 0) return 0.0;
    return (_todaySteps / goal).clamp(0.0, 1.0);
  }

  // Profile data
  Future<double> getUserHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_height') ?? 175.0; // cm
  }

  Future<void> setUserHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_height', height);
  }

  Future<double> getUserWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_weight') ?? 70.0; // kg
  }

  Future<void> setUserWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', weight);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '步数达人';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // Level logic: Level = sqrt(totalSteps / 1000)
  Future<int> getUserLevel() async {
    final totalSteps = await getTotalSteps();
    if (totalSteps <= 0) return 1;
    return (double.parse((totalSteps / 1000).toString()).floor()) ~/ 10 + 1;
  }
  
  // Alternative level: every 50,000 steps = 1 level
  Future<int> calculateLevel() async {
    final total = await getTotalSteps();
    return (total / 50000).floor() + 1;
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    switch (modeIndex) {
      case 1: return ThemeMode.dark;
      case 2: return ThemeMode.light;
      default: return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    int modeIndex = (mode == ThemeMode.dark) ? 1 : (mode == ThemeMode.light ? 2 : 0);
    await prefs.setInt('theme_mode', modeIndex);
  }

  // Water tracking
  Future<int> getTodayWater() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return prefs.getInt('water_today_$today') ?? 0;
  }

  Future<void> addWater(int glasses) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final current = prefs.getInt('water_today_$today') ?? 0;
    await prefs.setInt('water_today_$today', (current + glasses).clamp(0, 50));
  }

  // Sedentary reminder
  Future<bool> isSedentaryReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sedentary_reminder_enabled') ?? false;
  }

  Future<void> setSedentaryReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sedentary_reminder_enabled', enabled);
  }

  Future<int> getSedentaryInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('sedentary_interval') ?? 60;
  }

  Future<void> setSedentaryInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sedentary_interval', minutes);
  }

  // Averages
  Future<int> getWeeklyAverage() async {
    final now = DateTime.now();
    int total = 0;
    int days = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final s = _dailySteps[date] ?? 0;
      if (s > 0 || date == _todayDate) { total += s; days++; }
    }
    return days > 0 ? (total / days).round() : 0;
  }

  Future<int> getMonthlyAverage() async {
    final now = DateTime.now();
    int total = 0;
    int days = 0;
    for (int i = 0; i < 30; i++) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final s = _dailySteps[date] ?? 0;
      if (s > 0 || date == _todayDate) { total += s; days++; }
    }
    return days > 0 ? (total / days).round() : 0;
  }

  // Export
  Future<String> exportDataAsCSV() async {
    final now = DateTime.now();
    String csv = '日期,步数,卡路里,距离(km)\n';
    for (int i = 29; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final steps = _dailySteps[date] ?? 0;
      csv += '$date,$steps,${(steps * 0.04).toStringAsFixed(2)},${(steps * 0.7 / 1000).toStringAsFixed(3)}\n';
    }
    return csv;
  }

  void dispose() {
    _stepStreamController.close();
    _statusStreamController.close();
  }
}
