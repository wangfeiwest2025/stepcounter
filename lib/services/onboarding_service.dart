import 'package:shared_preferences/shared_preferences.dart';

/// 引导服务 - 管理新手引导状态
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  /// 检查引导是否已完成
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// 标记引导已完成
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// 重置引导状态（用于测试或重新展示引导）
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
  }

  /// 获取引导状态（同步方法，用于阻塞性检查）
  static bool getOnboardingCompletedSync(SharedPreferences prefs) {
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }
}
