import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/achievement.dart';
import '../services/gameification_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> 
    with SingleTickerProviderStateMixin {
  final GameificationService _gameService = GameificationService();
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AchievementCategory.values.length + 1, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // 监听新成就解锁
    _gameService.achievementUnlockedStream.listen((achievement) {
      _confettiController.play();
      _showAchievementUnlockedDialog(achievement as Achievement);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showAchievementUnlockedDialog(Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              '🎉 成就解锁！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAchievementIcon(achievement, size: 60),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${achievement.expReward} 经验值',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('太棒了！'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _gameService.achievements;
    final unlockedCount = _gameService.unlockedAchievementsCount;
    final totalCount = _gameService.totalAchievementsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就殿堂'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '全部'),
            ...AchievementCategory.values.map((cat) => 
              Tab(text: _getCategoryName(cat)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildProgressHeader(unlockedCount, totalCount),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementList(achievements),
                    ...AchievementCategory.values.map((cat) =>
                    _buildAchievementList(achievements.where((a) => (a as Achievement).category == cat).cast<Achievement>().toList()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '成就进度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlocked / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? unlocked / total : 0,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已解锁 ${(total > 0 ? (unlocked / total * 100) : 0).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无成就',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 先显示已解锁的,再显示未解锁的
    achievements.sort((a, b) {
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return 0;
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLocked ? 1 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isLocked
              ? null
              : LinearGradient(
                  colors: [
                    _getCategoryColor(achievement.category).withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildAchievementIcon(achievement),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                isLocked ? '???' : achievement.description,
                style: TextStyle(
                  color: isLocked ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '解锁于 ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLocked 
                  ? Colors.grey[200]
                  : _getCategoryColor(achievement.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${achievement.expReward} EXP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLocked 
                    ? Colors.grey 
                    : _getCategoryColor(achievement.category),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementIcon(Achievement achievement, {double size = 50}) {
    final isLocked = !achievement.isUnlocked;
    final icon = _getIconData(achievement.iconName);
    final color = isLocked ? Colors.grey : _getCategoryColor(achievement.category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'play_arrow': Icons.play_arrow,
      'directions_walk': Icons.directions_walk,
      'trending_up': Icons.trending_up,
      'emoji_events': Icons.emoji_events,
      'military_tech': Icons.military_tech,
      'map': Icons.map,
      'explore': Icons.explore,
      'local_fire_department': Icons.local_fire_department,
      'whatshot': Icons.whatshot,
      'stars': Icons.stars,
      'wb_sunny': Icons.wb_sunny,
      'nights_stay': Icons.nights_stay,
    };
    return iconMap[iconName] ?? Icons.emoji_events;
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.steps:
        return Colors.blue;
      case AchievementCategory.distance:
        return Colors.green;
      case AchievementCategory.streak:
        return Colors.orange;
      case AchievementCategory.challenge:
        return Colors.purple;
      case AchievementCategory.special:
        return Colors.amber;
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.steps:
        return '步数';
      case AchievementCategory.distance:
        return '距离';
      case AchievementCategory.streak:
        return '连续';
      case AchievementCategory.challenge:
        return '挑战';
      case AchievementCategory.special:
        return '特殊';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    
    return '${date.month}月${date.day}日';
  }
}
