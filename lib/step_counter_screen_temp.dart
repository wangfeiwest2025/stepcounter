import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';
import 'step_counter_service.dart';
import 'package:intl/intl.dart';
import 'privacy_policy_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  final StepCounterService _stepCounterService = StepCounterService();
  int _currentSteps = 0;
  String _pedestrianStatus = 'Unknown';
  int _dailyGoal = 10000;
  double _goalCompletion = 0.0;
  late StreamSubscription<int> _stepSubscription;
  late StreamSubscription<String> _statusSubscription;

  // Confetti controller for celebration
  late ConfettiController _confettiController;
  bool _hasShownCelebration = false;

  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _initializeStepCounter();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await _stepCounterService.getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = prefs;
      });
    }
  }

  void _initializeStepCounter() async {
    setState(() {
      _currentSteps = _stepCounterService.todaySteps;
    });

    _dailyGoal = await _stepCounterService.getDailyGoal();
    _updateGoalCompletion();

    _stepSubscription = _stepCounterService.stepStream.listen((steps) {
      if (mounted) {
        setState(() {
          _currentSteps = steps;
        });
        _updateGoalCompletion();
        _checkGoalCompletion();
      }
    });

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
      _showGoalAchievedDialog();
    } else if (_goalCompletion < 1.0) {
      _hasShownCelebration = false;
    }
  }

  void _showGoalAchievedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            Text(
              '🎉 恭喜达成目标！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              '您已完成今日步数目标',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('太棒了！'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription.cancel();
    _statusSubscription.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _setDailyGoal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int newGoal = _dailyGoal;
        return AlertDialog(
          title: Text('设置每日步数目标'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '输入步数目标',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
            ),
            onChanged: (value) {
              newGoal = int.tryParse(value) ?? _dailyGoal;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('设置'),
              onPressed: () async {
                await _stepCounterService.setDailyGoal(newGoal);
                setState(() {
                  _dailyGoal = newGoal;
                  _hasShownCelebration = false;
                });
                _updateGoalCompletion();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleTheme() async {
    ThemeMode newMode;
    if (_themeMode == ThemeMode.system) {
      newMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.system;
    }

    await _stepCounterService.setThemeMode(newMode);
    if (mounted) {
      setState(() {
        _themeMode = newMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text('StepCounter'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: _toggleTheme,
              tooltip: '切换主题',
            ),
            IconButton(
              icon: Icon(Icons.privacy_tip),
              onPressed: () {
                PrivacyPolicyDialog.showInfoDialog(context);
              },
              tooltip: '隐私政策',
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _setDailyGoal,
              tooltip: '设置目标',
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildStepCountCard(),
                  SizedBox(height: 20),
                  _buildStatsCards(),
                  SizedBox(height: 20),
                  _buildGoalProgressCard(),
                  SizedBox(height: 20),
                  _buildWeeklyChartCard(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日步数',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    TextButton(
                      onPressed: () async {
                        bool hasPermission = await _stepCounterService.requestActivityPermission();

                        if (!hasPermission) {
                          var status =
                              await Permission.activityRecognition.status;

                          if (status.isPermanentlyDenied) {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('需要权限'),
                                  content:
                                      Text('计步功能需要健身运动权限。您之前已拒绝该权限，请前往系统设置开启。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        openAppSettings();
                                      },
                                      child: Text('去设置'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        } else {
                          _stepCounterService.activateService();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                  SizedBox(width: 16),
                                  Text('尝试激活传感器...'),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '激活',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            '$_currentSteps',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_walk, size: 20, color: Colors.white.withOpacity(0.7)),
                SizedBox(width: 8),
                Text(
                  '状态: $_pedestrianStatus',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.local_fire_department,
            '卡路里',
            '${_stepCounterService.caloriesBurned.toStringAsFixed(0)}',
            'kcal',
            Colors.orange,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            Icons.straighten,
            '距离',
            '${_stepCounterService.distanceInKm.toStringAsFixed(2)}',
            'km',
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日目标',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Text(
                '${_dailyGoal}步',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            percent: _goalCompletion.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_goalCompletion * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  '已完成',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
            backgroundColor: Colors.green.shade100,
          ),
          SizedBox(height: 10),
          Text(
            '${_currentSteps} / $_dailyGoal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard() {
    final recentSteps = _stepCounterService.getRecentDaysSteps(7);
    final chartData = recentSteps.entries.map((entry) {
      return BarChartGroupData(
        x: recentSteps.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 12,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '近七天统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _dailyGoal.toDouble(),
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final dates = recentSteps.keys.toList();
                        if (value.toInt() >= 0 &&
                            value.toInt() < dates.length) {
                          final date = dates[value.toInt()];
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MM/dd')
                                  .format(DateFormat('yyyy-MM-dd').parse(date)),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[700]),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: chartData,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

