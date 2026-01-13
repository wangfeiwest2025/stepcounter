import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_mode.dart';
import '../services/exercise_tracking_service.dart';

class ExerciseTrackingScreen extends StatefulWidget {
  const ExerciseTrackingScreen({super.key});

  @override
  State<ExerciseTrackingScreen> createState() => _ExerciseTrackingScreenState();
}

class _ExerciseTrackingScreenState extends State<ExerciseTrackingScreen> {
  final ExerciseTrackingService _trackingService = ExerciseTrackingService();
  Timer? _timer;
  Duration _sessionDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _trackingService.loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    final mode = _trackingService.currentMode;
    _trackingService.startExerciseSession(mode);
    
    // 开始计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_trackingService.currentSession != null) {
        setState(() {
          _sessionDuration = DateTime.now().difference(
            _trackingService.currentSession!.startTime,
          );
        });
      }
    });
    
    setState(() {});
  }

  void _stopSession() async {
    await _trackingService.stopExerciseSession();
    _timer?.cancel();
    setState(() {
      _sessionDuration = Duration.zero;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('运动已结束,数据已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = _trackingService.currentSession;
    final isActive = currentSession != null && currentSession.isActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('运动追踪'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isActive) ...[
              _buildModeSelector(),
              const SizedBox(height: 24),
              _buildTodayStats(),
              const SizedBox(height: 24),
              _buildStartButton(),
            ] else ...[
              _buildActiveSession(currentSession),
              const SizedBox(height: 24),
              _buildStopButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择运动模式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ExerciseModes.all.map((mode) {
                final isSelected = _trackingService.currentMode == mode.type;
                return _buildModeChip(mode, isSelected);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(ExerciseMode mode, bool isSelected) {
    final icon = _getIconData(mode.iconName);
    
    return InkWell(
      onTap: () {
        _trackingService.setExerciseMode(mode.type);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              mode.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    final stats = _trackingService.getTodayStatsByMode();
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日运动统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '今天还没有运动记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...stats.entries.map((entry) {
                final mode = _trackingService.getExerciseMode(entry.key);
                final data = entry.value;
                return _buildStatRow(
                  mode.name,
                  _getIconData(mode.iconName),
                  data,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String modeName, IconData icon, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data['steps']}步 • ${(data['distance'] / 1000).toStringAsFixed(2)}km',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${data['sessions']}次',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(ExerciseSession session) {
    final mode = _trackingService.getExerciseMode(session.modeType);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.teal[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIconData(mode.iconName), color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  mode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '运动中...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            // 时长
            StreamBuilder<ExerciseSession?>(
              stream: _trackingService.sessionStream,
              builder: (context, snapshot) {
                return Text(
                  _formatDuration(_sessionDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // 统计数据
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSessionStat(
                  '步数',
                  '${session.steps}',
                  Icons.directions_walk,
                ),
                _buildSessionStat(
                  '距离',
                  '${(session.distance / 1000).toStringAsFixed(2)} km',
                  Icons.map,
                ),
                _buildSessionStat(
                  '卡路里',
                  '${session.calories.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _startSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.play_arrow, size: 32),
            SizedBox(width: 8),
            Text(
              '开始运动',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _stopSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.stop, size: 32),
            SizedBox(width: 8),
            Text(
              '结束运动',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'directions_walk': Icons.directions_walk,
      'directions_run': Icons.directions_run,
      'directions_bike': Icons.directions_bike,
      'terrain': Icons.terrain,
      'pool': Icons.pool,
    };
    return iconMap[iconName] ?? Icons.fitness_center;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

// 运动历史记录页面
class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ExerciseTrackingService();
    final history = service.exerciseHistory.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('运动历史'),
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '还没有运动记录',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];
                return _buildHistoryCard(context, session);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ExerciseSession session) {
    final service = ExerciseTrackingService();
    final mode = service.getExerciseMode(session.modeType);
    final icon = _getIconData(mode.iconName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        title: Text(
          mode.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(session.startTime),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(
                  Icons.directions_walk,
                  '${session.steps}步',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.map,
                  '${(session.distance / 1000).toStringAsFixed(2)}km',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.timer,
                  _formatDuration(session.duration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'directions_walk': Icons.directions_walk,
      'directions_run': Icons.directions_run,
      'directions_bike': Icons.directions_bike,
      'terrain': Icons.terrain,
      'pool': Icons.pool,
    };
    return iconMap[iconName] ?? Icons.fitness_center;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h${minutes}m';
    }
    return '${minutes}m';
  }
}
