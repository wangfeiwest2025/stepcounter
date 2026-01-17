import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';

/// 简化的功能导览组件 - 不依赖外部包
class FeatureTour {
  /// 显示功能导览（简化版本）
  static Future<void> show({
    required GlobalKey homeKey,
    required GlobalKey statsKey,
    required GlobalKey healthKey,
    required GlobalKey profileKey,
    required VoidCallback onTourEnd,
  }) async {
    // 检查是否已完成导览
    final completed = await OnboardingService.isOnboardingCompleted();
    if (completed) {
      onTourEnd();
      return;
    }

    // 获取当前上下文
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      onTourEnd();
      return;
    }

    // 显示导览对话框
    await _showTourDialog(context, onTourEnd);
  }

  static Future<void> _showTourDialog(BuildContext context, VoidCallback onTourEnd) async {
    final steps = [
      TourStep(
        title: '主页',
        description: '查看实时步数和目标进度',
        icon: Icons.directions_walk,
      ),
      TourStep(
        title: '数据分析',
        description: '查看每日、每周、每月的步数统计',
        icon: Icons.bar_chart,
      ),
      TourStep(
        title: '健康数据',
        description: '查看运动记录和健康指标',
        icon: Icons.health_and_safety,
      ),
      TourStep(
        title: '个人中心',
        description: '管理成就、挑战和个人设置',
        icon: Icons.person,
      ),
    ];

    int currentStep = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final step = steps[currentStep];
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 进度指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentStep == index ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.icon, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  
                  // 标题
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 描述
                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 按钮
                  Row(
                    children: [
                      if (currentStep > 0)
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                currentStep--;
                              });
                            },
                            child: const Text('上一步'),
                          ),
                        ),
                      if (currentStep > 0) const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentStep < steps.length - 1) {
                              setState(() {
                                currentStep++;
                              });
                            } else {
                              OnboardingService.completeOnboarding();
                              Navigator.of(context).pop();
                              onTourEnd();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            currentStep < steps.length - 1 ? '下一步' : '开始使用',
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 跳过按钮
                  if (currentStep < steps.length - 1)
                    TextButton(
                      onPressed: () {
                        OnboardingService.completeOnboarding();
                        Navigator.of(context).pop();
                        onTourEnd();
                      },
                      child: Text(
                        '跳过',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 隐藏导览
  static void hide() {
    // 如果需要，可以扩展为全局控制器
  }

  /// 重置导览（用于测试）
  static Future<void> reset() async {
    await OnboardingService.resetOnboarding();
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData icon;

  TourStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// 导航服务 - 用于获取当前上下文
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
