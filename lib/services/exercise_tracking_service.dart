import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/exercise_mode.dart';

class ExerciseTrackingService {
  static final ExerciseTrackingService _instance = ExerciseTrackingService._internal();
  factory ExerciseTrackingService() => _instance;
  ExerciseTrackingService._internal();

  // 当前活动中的运动会话
  ExerciseSession? _currentSession;
  
  // 历史运动记录
  List<ExerciseSession> _exerciseHistory = [];
  
  // 当前选择的运动模式
  ExerciseModeType _currentMode = ExerciseModeType.walking;
  
  // Streams
  final StreamController<ExerciseSession?> _sessionStreamController = 
      StreamController<ExerciseSession?>.broadcast();
  final StreamController<ExerciseModeType> _modeStreamController = 
      StreamController<ExerciseModeType>.broadcast();

  Stream<ExerciseSession?> get sessionStream => _sessionStreamController.stream;
  Stream<ExerciseModeType> get modeStream => _modeStreamController.stream;
  
  ExerciseSession? get currentSession => _currentSession;
  List<ExerciseSession> get exerciseHistory => _exerciseHistory;
  ExerciseModeType get currentMode => _currentMode;

  // 开始新的运动会话
  Future<void> startExerciseSession(ExerciseModeType mode) async {
    if (_currentSession != null && _currentSession!.isActive) {
      throw Exception('已有活动中的运动会话');
    }

    _currentMode = mode;
    _currentSession = ExerciseSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      modeType: mode,
      startTime: DateTime.now(),
      duration: Duration.zero,
      isActive: true,
    );
    
    _sessionStreamController.sink.add(_currentSession);
    _modeStreamController.sink.add(_currentMode);
    
    print('开始运动: ${_getModeDisplayName(mode)}');
  }

  // 更新运动会话数据
  Future<void> updateSessionData({
    int? steps,
    double? distance,
    double? calories,
    LocationPoint? locationPoint,
  }) async {
    if (_currentSession == null || !_currentSession!.isActive) {
      return;
    }

    // 创建新的会话对象以触发stream更新
    final updatedRoute = locationPoint != null
        ? [..._currentSession!.route, locationPoint]
        : _currentSession!.route;

    _currentSession = ExerciseSession(
      id: _currentSession!.id,
      modeType: _currentSession!.modeType,
      steps: steps ?? _currentSession!.steps,
      distance: distance ?? _currentSession!.distance,
      calories: calories ?? _currentSession!.calories,
      duration: DateTime.now().difference(_currentSession!.startTime),
      startTime: _currentSession!.startTime,
      endTime: _currentSession!.endTime,
      route: updatedRoute,
      isActive: _currentSession!.isActive,
    );

    _sessionStreamController.sink.add(_currentSession);
  }

  // 结束运动会话
  Future<void> stopExerciseSession() async {
    if (_currentSession == null || !_currentSession!.isActive) {
      return;
    }

    _currentSession = ExerciseSession(
      id: _currentSession!.id,
      modeType: _currentSession!.modeType,
      steps: _currentSession!.steps,
      distance: _currentSession!.distance,
      calories: _currentSession!.calories,
      duration: DateTime.now().difference(_currentSession!.startTime),
      startTime: _currentSession!.startTime,
      endTime: DateTime.now(),
      route: _currentSession!.route,
      isActive: false,
    );

    // 保存到历史记录
    _exerciseHistory.add(_currentSession!);
    await _saveHistory();
    
    _sessionStreamController.sink.add(_currentSession);
    
    print('运动结束: ${_getModeDisplayName(_currentSession!.modeType)}');
    print('统计: ${_currentSession!.steps}步, ${(_currentSession!.distance / 1000).toStringAsFixed(2)}km, ${_currentSession!.calories.toStringAsFixed(0)}千卡');
    
    _currentSession = null;
  }

  // 切换运动模式
  Future<void> setExerciseMode(ExerciseModeType mode) async {
    _currentMode = mode;
    _modeStreamController.sink.add(_currentMode);
    await _saveCurrentMode();
  }

  // 获取今日不同运动模式的统计
  Map<ExerciseModeType, Map<String, dynamic>> getTodayStatsByMode() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todaySessions = _exerciseHistory.where((session) {
      final sessionDate = DateFormat('yyyy-MM-dd').format(session.startTime);
      return sessionDate == today;
    }).toList();

    final Map<ExerciseModeType, Map<String, dynamic>> stats = {};
    
    for (var mode in ExerciseModeType.values) {
      final modeSessions = todaySessions.where((s) => s.modeType == mode).toList();
      
      if (modeSessions.isNotEmpty) {
        final totalSteps = modeSessions.fold<int>(0, (sum, s) => sum + s.steps);
        final totalDistance = modeSessions.fold<double>(0, (sum, s) => sum + s.distance);
        final totalCalories = modeSessions.fold<double>(0, (sum, s) => sum + s.calories);
        final totalDuration = modeSessions.fold<Duration>(
          Duration.zero, 
          (sum, s) => sum + s.duration,
        );
        
        stats[mode] = {
          'steps': totalSteps,
          'distance': totalDistance,
          'calories': totalCalories,
          'duration': totalDuration,
          'sessions': modeSessions.length,
        };
      }
    }
    
    return stats;
  }

  // 获取运动模式显示名称
  String _getModeDisplayName(ExerciseModeType mode) {
    final exerciseMode = ExerciseModes.all.firstWhere(
      (m) => m.type == mode,
      orElse: () => ExerciseModes.walking,
    );
    return exerciseMode.name;
  }

  // 获取运动模式
  ExerciseMode getExerciseMode(ExerciseModeType type) {
    return ExerciseModes.all.firstWhere(
      (m) => m.type == type,
      orElse: () => ExerciseModes.walking,
    );
  }

  // ==================== 数据持久化 ====================
  
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载运动历史
    final historyJson = prefs.getString('exercise_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _exerciseHistory = decoded
          .map((json) => ExerciseSession.fromJson(json))
          .toList();
    }
    
    // 加载当前模式
    final modeIndex = prefs.getInt('current_exercise_mode') ?? 0;
    if (modeIndex >= 0 && modeIndex < ExerciseModeType.values.length) {
      _currentMode = ExerciseModeType.values[modeIndex];
      _modeStreamController.sink.add(_currentMode);
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 只保留最近100条记录
    if (_exerciseHistory.length > 100) {
      _exerciseHistory = _exerciseHistory.sublist(
        _exerciseHistory.length - 100,
      );
    }
    
    final historyJson = jsonEncode(
      _exerciseHistory.map((s) => s.toJson()).toList(),
    );
    await prefs.setString('exercise_history', historyJson);
  }

  Future<void> _saveCurrentMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_exercise_mode', _currentMode.index);
  }

  void dispose() {
    _sessionStreamController.close();
    _modeStreamController.close();
  }
}
