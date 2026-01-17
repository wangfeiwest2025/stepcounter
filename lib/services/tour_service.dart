import 'package:shared_preferences/shared_preferences.dart';

/// 导览服务 - 管理功能导览状态
class TourService {
  static const String _keyTourCompleted = 'tour_completed';

  /// 检查导览是否已完成
  static Future<bool> isTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTourCompleted) ?? false;
  }

  /// 标记导览已完成
  static Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourCompleted, true);
  }

  /// 重置导览状态（用于测试或重新展示导览）
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTourCompleted);
  }

  /// 获取导览状态（同步方法，用于阻塞性检查）
  static bool getTourCompletedSync(SharedPreferences prefs) {
    return prefs.getBool(_keyTourCompleted) ?? false;
  }
}
