import 'dart:async';
import 'package:flutter/services.dart';

/// 震动反馈服务
/// 使用Flutter MethodChannel直接调用Android原生震动API
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  static const MethodChannel _vibratorChannel = MethodChannel('com.example.vibrator');

  /// 轻触反馈 - 用于普通按钮点击
  Future<void> light() async {
    try {
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 10,
        'amplitude': 64,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 中等震动 - 用于重要操作
  Future<void> medium() async {
    try {
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 20,
        'amplitude': 128,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 强烈震动 - 用于重要事件
  Future<void> heavy() async {
    try {
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 30,
        'amplitude': 255,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 成功震动 - 用于目标达成、成就解锁
  Future<void> success() async {
    try {
      // 连续两次中等震动，间隔100ms
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 100,
        'amplitude': 128,
      });
      await Future.delayed(const Duration(milliseconds: 150));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 100,
        'amplitude': 128,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 成就解锁震动 - 激励模式
  Future<void> achievement() async {
    try {
      // 三次震动模式：短-长-短
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 50,
        'amplitude': 128,
      });
      await Future.delayed(const Duration(milliseconds: 100));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 200,
        'amplitude': 192,
      });
      await Future.delayed(const Duration(milliseconds: 100));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 50,
        'amplitude': 128,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 里程碑震动 - 用于1000、5000、10000步等里程碑
  Future<void> milestone() async {
    try {
      // 四次渐进式震动
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 50,
        'amplitude': 64,
      });
      await Future.delayed(const Duration(milliseconds: 80));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 75,
        'amplitude': 128,
      });
      await Future.delayed(const Duration(milliseconds: 80));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 100,
        'amplitude': 192,
      });
      await Future.delayed(const Duration(milliseconds: 80));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 150,
        'amplitude': 255,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 警告震动 - 用于错误提示
  Future<void> warning() async {
    try {
      // 两次快速震动
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 100,
        'amplitude': 192,
      });
      await Future.delayed(const Duration(milliseconds: 80));
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': 100,
        'amplitude': 192,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 连续震动（用于特殊效果）
  Future<void> vibrate({int duration = 200, int amplitude = 128}) async {
    try {
      await _vibratorChannel.invokeMethod('vibrate', {
        'duration': duration,
        'amplitude': amplitude,
      });
    } on PlatformException catch (e) {
      print('震动反馈失败: $e');
    }
  }

  /// 停止震动
  Future<void> stop() async {
    try {
      await _vibratorChannel.invokeMethod('cancel');
    } on PlatformException catch (e) {
      print('停止震动失败: $e');
    }
  }
}
