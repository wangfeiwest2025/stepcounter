import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/challenge.dart';
import '../services/gameification_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final GameificationService _gameService = GameificationService();

  @override
  Widget build(BuildContext context) {
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
                .where((c) => (c as Challenge).type == ChallengeType.daily && (c as Challenge).isCompleted)
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
              Icon(Icons.emoji_events, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                '挑战进度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('活跃挑战', '${activeChallenges.length}'),
              _buildStatItem('今日完成', '$completedToday'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenges() {
    final dailyChallenges = _gameService.activeChallenges
        .where((c) => (c as Challenge).type == ChallengeType.daily)
        .cast<Challenge>()
        .toList();

    if (dailyChallenges.isEmpty) {
      return _buildEmptyState('今日挑战已全部完成！');
    }

    return Column(
      children: dailyChallenges.map((challenge) => 
        _buildChallengeCard(challenge)
      ).toList(),
    );
  }

  Widget _buildWeeklyChallenges() {
    final weeklyChallenges = _gameService.activeChallenges
        .where((c) => (c as Challenge).type == ChallengeType.weekly)
        .cast<Challenge>()
        .toList();

    if (weeklyChallenges.isEmpty) {
      return _buildEmptyState('本周挑战已全部完成！');
    }

    return Column(
      children: weeklyChallenges.map((challenge) => 
        _buildChallengeCard(challenge)
      ).toList(),
    );
  }

  Widget _buildCompletedChallenges() {
    final completed = _gameService.completedChallenges.take(5).cast<Challenge>().toList();

    if (completed.isEmpty) {
      return _buildEmptyState('还没有完成的挑战');
    }

    return Column(
      children: completed.map((challenge) => 
        _buildChallengeCard(challenge, isCompleted: true)
      ).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, {bool isCompleted = false}) {
    final Color accentColor = _getChallengeColor(challenge.type);
    final progress = challenge.progress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted 
              ? null 
              : LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 进度圆环
              CircularPercentIndicator(
                radius: 35,
                lineWidth: 6,
                percent: progress,
                center: Icon(
                  isCompleted ? Icons.check : _getChallengeIcon(challenge),
                  color: accentColor,
                  size: 28,
                ),
                progressColor: accentColor,
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              // 挑战信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            challenge.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.grey : Colors.black87,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                        ),
                        if (!isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              challenge.timeRemaining,
                              style: TextStyle(
                                fontSize: 11,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${challenge.currentValue}/${challenge.targetValue}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.stars, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '+${challenge.expReward} 经验值',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChallengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return Colors.blue;
      case ChallengeType.weekly:
        return Colors.green;
      case ChallengeType.special:
        return Colors.purple;
    }
  }

  IconData _getChallengeIcon(Challenge challenge) {
    if (challenge.id.contains('steps')) return Icons.directions_walk;
    if (challenge.id.contains('distance')) return Icons.map;
    if (challenge.id.contains('calories')) return Icons.local_fire_department;
    if (challenge.id.contains('streak')) return Icons.whatshot;
    return Icons.flag;
  }
}
