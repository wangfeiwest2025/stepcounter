import 'package:flutter/material.dart';

/// 增强的空状态组件，提供引导提示
class EnhancedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? tips;
  final Color? iconColor;

  const EnhancedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.tips,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (iconColor ?? primaryColor).withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 描述
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 操作按钮（如果有）
            if (actionLabel != null && onAction != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor ?? primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // 提示列表（如果有）
            if (tips != null && tips!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outlined, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '小贴士',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...tips!.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                          Expanded(child: tip),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 成就空状态组件
class AchievementEmptyState extends StatelessWidget {
  const AchievementEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      icon: Icons.emoji_events_outlined,
      iconColor: Colors.amber,
      title: '还没有成就',
      description: '开始走路来解锁你的第一个成就吧！每达成一个目标，你都会获得经验值奖励。',
      actionLabel: '查看如何获得成就',
      onAction: () {
        // 滚动到成就说明或打开帮助
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('提示：完成步数挑战、连续打卡、达到里程目标都可以解锁成就！'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.amber[700],
          ),
        );
      },
      tips: [
        const Text('步数达到100步即可解锁第一个成就"启程"'),
        const Text('单日步行5000步可解锁"健步如飞"成就'),
        const Text('连续打卡3天可获得"坚持三天"成就'),
      ],
    );
  }
}

/// 挑战空状态组件
class ChallengeEmptyState extends StatelessWidget {
  final String subtitle;
  
  const ChallengeEmptyState({super.key, this.subtitle = '明天再来看看有什么新挑战吧！'});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      icon: Icons.military_tech_outlined,
      iconColor: Colors.purple,
      title: '暂无挑战任务',
      description: '挑战任务会在每天/每周开始时自动生成，完成挑战可获得额外经验值奖励！',
      tips: [
        const Text('每日挑战：每天凌晨自动刷新'),
        const Text('每周挑战：每周一自动刷新'),
        Text(subtitle),
      ],
    );
  }
}

/// 历史记录空状态
class HistoryEmptyState extends StatelessWidget {
  final String activityType;
  
  const HistoryEmptyState({super.key, this.activityType = '运动记录'});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      icon: Icons.history,
      iconColor: Colors.blue,
      title: '暂无$activityType',
      description: '开始你的第一次运动吧！完成运动后会在这里留下记录。',
      actionLabel: '开始运动',
      onAction: () {
        // 导航到运动页面
      },
      tips: [
        const Text('支持步行、跑步、骑行、徒步、游泳等多种运动模式'),
        const Text('运动过程中会实时记录步数、距离和消耗的卡路里'),
      ],
    );
  }
}
