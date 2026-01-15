import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';
import 'step_counter_service.dart';
import 'services/gameification_service.dart';
import 'services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'privacy_policy_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_settings_sheet.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen>
    with SingleTickerProviderStateMixin {
  final StepCounterService _stepCounterService = StepCounterService();
  final GameificationService _gameService = GameificationService();
  
  // Data States
  int _currentSteps = 0;
  String _pedestrianStatus = 'Unknown';
  int _dailyGoal = 10000;
  double _goalCompletion = 0.0;
  String _userName = '步数达人';
  double _calories = 0;
  double _distance = 0;
  
  // Streams
  late StreamSubscription<int> _stepSubscription;
  late StreamSubscription<String> _statusSubscription;

  // Animation & UI Controllers
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasShownCelebration = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    
    // Heartbeat/Pulse animation for the main circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeStepCounter();
    _loadProfileData();
  }

  @override
  void dispose() {
    _stepSubscription.cancel();
    _statusSubscription.cancel();
    _confettiController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final name = await _stepCounterService.getUserName();
    final cal = await _stepCounterService.getCaloriesBurned();
    final dist = await _stepCounterService.getDistanceInKm();
    if (mounted) {
      setState(() {
        _userName = name;
        _calories = cal;
        _distance = dist;
      });
    }
  }

  void _initializeStepCounter() async {
    // Initial fetch
    _currentSteps = _stepCounterService.todaySteps;
    _dailyGoal = await _stepCounterService.getDailyGoal();
    _updateGoalCompletion();

    // Listen to steps
    _stepSubscription = _stepCounterService.stepStream.listen((steps) async {
      final cal = await _stepCounterService.getCaloriesBurned();
      final dist = await _stepCounterService.getDistanceInKm();
      if (mounted) {
        setState(() {
          _currentSteps = steps;
          _calories = cal;
          _distance = dist;
        });
        _updateGoalCompletion();
        _checkGoalCompletion();
        
        // 检查成就和挑战
        await _checkGameificationProgress(steps, dist * 1000, cal);
      }
    });

    // Listen to status (Walking, Stopped, etc.)
    _statusSubscription = _stepCounterService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _pedestrianStatus = status;
        });
      }
    });
  }

  void _updateGoalCompletion() async {
    final completion = await _stepCounterService.getGoalCompletion();
    if (mounted) {
      setState(() {
        _goalCompletion = completion;
      });
    }
  }

  void _checkGoalCompletion() {
    if (_goalCompletion >= 1.0 && !_hasShownCelebration) {
      _confettiController.play();
      _hasShownCelebration = true;
      // 触发成功震动
      HapticService().success();
      _showGoalAchievedDialog();
    } else if (_goalCompletion < 1.0) {
      _hasShownCelebration = false;
    }
  }

  // 检查游戏化进度 (成就、挑战)
  Future<void> _checkGameificationProgress(int steps, double distanceInMeters, double calories) async {
    // 检查步数里程碑并触发震动
    _checkStepMilestones(steps);

    // 检查步数相关成就
    await _gameService.checkStepAchievements(steps);

    // 检查距离相关成就
    await _gameService.checkDistanceAchievements(distanceInMeters);

    // 更新挑战进度
    await _gameService.checkChallengesForSteps(steps, distanceInMeters, calories);

    // 检查连续打卡成就
    final streak = await _stepCounterService.getCurrentStreak();
    await _gameService.checkStreakAchievements(streak);
  }

  // 检查步数里程碑
  void _checkStepMilestones(int steps) {
    // 里程碑: 1000, 5000, 10000, 20000, 30000...
    final milestones = [1000, 5000, 10000, 20000, 30000, 50000];

    for (var milestone in milestones) {
      if (steps == milestone) {
        HapticService().milestone();
        break; // 只触发一次
      } else if (steps > milestone && steps < milestone + 100) {
        // 在里程碑后的100步内也触发，避免错过
        HapticService().milestone();
        break;
      }
      }
  }

  // 处理下拉刷新
  Future<void> _handleRefresh() async {
    // 触发轻微信动
    await HapticService().light();

    // 同步数据
    _stepCounterService.synchronize();

    // 重新加载个人资料数据
    await _loadProfileData();

    // 显示刷新提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 数据已刷新'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showGoalAchievedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
              child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 目标达成！',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '你已经走了 $_currentSteps 步\n坚持就是胜利！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B66FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('太棒了', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background color based on progress
    final Color primaryColor = _goalCompletion >= 1.0 
        ? const Color(0xFF00C853) // Green for success
        : const Color(0xFF6B66FF); // Default Purple-Blue

     return Scaffold(
       backgroundColor: Colors.white,
       body: Stack(
         children: [
           // Main Content with RefreshIndicator
           RefreshIndicator(
             onRefresh: _handleRefresh,
             backgroundColor: Colors.white,
             color: const Color(0xFF6B66FF),
             child: CustomScrollView(
               controller: _scrollController,
               physics: const BouncingScrollPhysics(),
               slivers: [
                 _buildAppBar(), // Simplified AppBar
                 SliverToBoxAdapter(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const SizedBox(height: 10), // Space for status bar/AppBar
                         _buildHeader(), // New Header Section
                         const SizedBox(height: 20),
                         Center(child: _buildMainIndicator(primaryColor)),
                         const SizedBox(height: 30),
                         Center(child: _buildStatusChip(primaryColor)),
                         const SizedBox(height: 40),
                         _buildStatsGrid(),
                         const SizedBox(height: 30),
                         _buildInsightCard(primaryColor),
                         const SizedBox(height: 30),
                         _buildWeeklyChart(primaryColor),
                         const SizedBox(height: 100),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool hasPermission = await _stepCounterService.requestActivityPermission();
          if (hasPermission) {
            _stepCounterService.synchronize();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('正在同步传感器数据...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.black87,
                ),
              );
            }
          } else {
             if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('需要权限才能同步步数')),
              );
            }
          }
        },
        elevation: 4,
        highlightElevation: 8,
        label: const Text('同步', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.sync_rounded),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0.0, // No expansion needed
      toolbarHeight: 56.0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true, // Float to allow full view
      pinned: false,  // Don't pin to avoid covering content
      systemOverlayStyle: null, // Use default
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black54),
            onPressed: () => PrivacyPolicyDialog.showInfoDialog(context),
          ),
        ),
      ],
    );
  }

  // Removed _showProfileSettings method as it is redundant

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(Color color) {
    IconData statusIcon = Icons.accessibility_new_rounded;
    String statusText = '准备就绪';
    
    switch (_pedestrianStatus) {
      case 'walking':
        statusIcon = Icons.directions_walk_rounded;
        statusText = '正在行走';
        break;
      case 'stopped':
        statusIcon = Icons.accessibility_rounded;
        statusText = '静止';
        break;
      default:
        statusIcon = Icons.help_outline_rounded;
        statusText = _pedestrianStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIndicator(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pedestrianStatus == 'walking' ? _pulseAnimation.value : 1.0,
          child: CircularPercentIndicator(
            radius: 130.0,
            lineWidth: 25.0,
            animation: true,
            animationDuration: 1000,
            animateFromLastPercent: true,
            percent: _goalCompletion.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Shrink wrap to ensure true center
              children: [
                Icon(Icons.directions_run_rounded, size: 40, color: color),
                Text(
                  '$_currentSteps',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 52, // Slightly increased for better balance
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.0,  // Remove font padding to ensure centering
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '目标 $_dailyGoal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey[100]!,
            linearGradient: LinearGradient(
              colors: [
                color.withOpacity(0.5),
                color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          '卡路里',
          '${_calories.toStringAsFixed(0)}',
          '千卡',
          Icons.local_fire_department_rounded,
          Colors.orange,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(
          '距离',
          '${_distance.toStringAsFixed(2)}',
          '公里',
          Icons.map_rounded,
          Colors.green,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(
          '时长',
          '${(_currentSteps / 100).toStringAsFixed(0)}', // Rough estimate
          '分钟',
          Icons.timer_rounded,
          Colors.blue,
        )),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日洞察',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _goalCompletion < 0.3 
                      ? '新的一天，走起来！' 
                      : (_goalCompletion < 0.8 
                          ? '坚持住，胜利在望！' 
                          : '太强了，目标达成！'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyChart(Color color) {
    final recentSteps = _stepCounterService.getRecentDaysSteps(7);
    final maxSteps = recentSteps.values.fold(0, (prev, curr) => max(prev, curr));
    // Round visual max up to nearest 1000
    final visualMax = ((maxSteps + 1000) / 1000).ceil() * 1000.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '最近7天趋势',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 24, bottom: 0, left: 16, right: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: visualMax > 0 ? visualMax : 10000,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} 步',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, m) {
                      final keys = recentSteps.keys.toList();
                      if (v.toInt() >= 0 && v.toInt() < keys.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            keys[v.toInt()].substring(8), // Show day "DD"
                            style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: recentSteps.entries.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final date = entry.value.key;
                final steps = entry.value.value;
                final isToday = date == DateFormat('yyyy-MM-dd').format(DateTime.now());
                
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: steps.toDouble(),
                      color: isToday ? color : const Color(0xFFF1F2F6),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: visualMax > 0 ? visualMax : 10000,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
