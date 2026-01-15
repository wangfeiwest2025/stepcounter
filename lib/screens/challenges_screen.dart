import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/challenge.dart';
import '../services/gameification_service.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/empty_state.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final GameificationService _gameService = GameificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 模拟加载延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('挑战任务'),
          elevation: 0,
        ),
        body: const ListLoadingSkeleton(itemCount: 6),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('挑战任务'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Challenge>>(
        stream: _gameService.challengeUpdateStream,
        initialData: _gameService.activeChallenges,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMotivationalCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('今日挑战', Icons.today),
                const SizedBox(height: 12),
                _buildDailyChallenges(),
                const SizedBox(height: 24),
                _buildSectionTitle('本周挑战', Icons.date_range),
                const SizedBox(height: 12),
                _buildWeeklyChallenges(),
                const SizedBox(height: 24),
                _buildSectionTitle('已完成', Icons.check_circle),
                const SizedBox(height: 12),
                _buildCompletedChallenges(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMotivationalCard() {
    final activeChallenges = _gameService.activeChallenges;
    final completedToday = _gameService.completedChallenges
        .where((c) => c.type == ChallengeType.daily && c.isCompleted)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[400]!, Colors.purple[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                '今日挑战',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activeChallenges.length}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '进行中',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedToday',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '已完成',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenges() {
    final dailyChallenges = _gameService.activeChallenges
        .where((c) => c.type == ChallengeType.daily)
        .toList();

    if (dailyChallenges.isEmpty) {
      return _buildEmptyState('今日暂无挑战', '明天再来看看有什么新挑战吧！');
    }

    return Column(
      children: dailyChallenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
    );
  }

  Widget _buildWeeklyChallenges() {
    final weeklyChallenges = _gameService.activeChallenges
        .where((c) => c.type == ChallengeType.weekly)
        .toList();

    if (weeklyChallenges.isEmpty) {
      return _buildEmptyState('本周暂无挑战', '期待下周的挑战吧！');
    }

    return Column(
      children: weeklyChallenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
    );
  }

  Widget _buildCompletedChallenges() {
    final completedChallenges = _gameService.completedChallenges;

    if (completedChallenges.isEmpty) {
      return _buildEmptyState('暂无已完成挑战', '完成挑战可获得经验值奖励！');
    }

    return Column(
      children: completedChallenges.map((challenge) => _buildChallengeCard(challenge, isCompleted: true)).toList(),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return EnhancedEmptyState(
      icon: Icons.inbox_outlined,
      iconColor: Colors.grey,
      title: title,
      description: subtitle,
      tips: [
        const Text('挑战任务会在每天/每周开始时自动生成'),
        const Text('完成挑战可获得额外经验值奖励'),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge, {bool isCompleted = false}) {
    final progress = (challenge.currentValue / challenge.targetValue).clamp(0.0, 1.0);

    return Card(
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted
              ? null
              : LinearGradient(
                  colors: [
                    _getChallengeColor(challenge.category).withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isCompleted ? Colors.grey : _getChallengeColor(challenge.category)).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : _getChallengeIcon(challenge),
                    color: isCompleted ? Colors.grey : _getChallengeColor(challenge.category),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCompleted ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.grey[200]
                        : _getChallengeColor(challenge.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge.expReward} EXP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.grey : _getChallengeColor(challenge.category),
                    ),
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getChallengeColor(challenge.category),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${challenge.currentValue}/${challenge.targetValue}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getChallengeColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.steps:
        return Colors.blue;
      case ChallengeCategory.distance:
        return Colors.green;
      case ChallengeCategory.calories:
        return Colors.orange;
      case ChallengeCategory.time:
        return Colors.purple;
      case ChallengeCategory.achievement:
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getChallengeIcon(Challenge challenge) {
    if (challenge.id.contains('steps')) {
      return Icons.directions_walk;
    } else if (challenge.id.contains('distance')) {
      return Icons.map;
    } else if (challenge.id.contains('calories')) {
      return Icons.local_fire_department;
    } else if (challenge.id.contains('time')) {
      return Icons.timer;
    } else if (challenge.id.contains('exercise')) {
      return Icons.fitness_center;
    }
    return Icons.star;
  }
}
