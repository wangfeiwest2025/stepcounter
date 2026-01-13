import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'step_counter_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StepCounterService _service = StepCounterService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  int _level = 1;
  int _totalSteps = 0;
  double _bmi = 0;
  String _bmiCategory = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _service.getUserName();
    final height = await _service.getUserHeight();
    final weight = await _service.getUserWeight();
    final goal = await _service.getDailyGoal();
    final level = await _service.calculateLevel();
    final total = await _service.getTotalSteps();

    setState(() {
      _nameController.text = name;
      _heightController.text = height.toString();
      _weightController.text = weight.toString();
      _goalController.text = goal.toString();
      _level = level;
      _totalSteps = total;
      _calculateBMI(height, weight);
    });
  }

  void _calculateBMI(double heightCm, double weightKg) {
    if (heightCm > 0) {
      final heightM = heightCm / 100;
      final bmi = weightKg / (heightM * heightM);
      setState(() {
        _bmi = bmi;
        if (bmi < 18.5) {
          _bmiCategory = '偏瘦';
        } else if (bmi < 24) {
          _bmiCategory = '标准';
        } else if (bmi < 28) {
          _bmiCategory = '超重';
        } else {
          _bmiCategory = '肥胖';
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    await _service.setUserName(_nameController.text);
    await _service.setUserHeight(double.tryParse(_heightController.text) ?? 175.0);
    await _service.setUserWeight(double.tryParse(_weightController.text) ?? 70.0);
    await _service.setDailyGoal(int.tryParse(_goalController.text) ?? 10000);
    _loadProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('个人资料已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLevelHeader(),
            const SizedBox(height: 20),
            _buildBMICard(),
            const SizedBox(height: 20),
            _buildProfileFields(),
            const SizedBox(height: 30),
            _buildStatsOverview(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              'Lv.$_level',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '累计行走: $_totalSteps 步',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_totalSteps % 50000) / 50000,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bmiIndicator('BMI', _bmi.toStringAsFixed(1), Colors.blue),
            const VerticalDivider(),
            _bmiIndicator('体型', _bmiCategory, _getBMIColor()),
          ],
        ),
      ),
    );
  }

  Widget _bmiIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _getBMIColor() {
    if (_bmiCategory == '标准') return Colors.green;
    if (_bmiCategory == '超重') return Colors.orange;
    if (_bmiCategory == '肥胖') return Colors.red;
    return Colors.blue;
  }

  Widget _buildProfileFields() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '每日目标 (步)',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '身高 (cm)',
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '体重 (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('成就勋章', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _badgeItem(Icons.workspace_premium, '初级入门', _totalSteps > 1000),
            _badgeItem(Icons.bolt, '速度之王', _totalSteps > 50000),
            _badgeItem(Icons.directions_run, '远足达人', _totalSteps > 200000),
            _badgeItem(Icons.emoji_events, '计步至尊', _totalSteps > 1000000),
          ],
        ),
      ],
    );
  }

  Widget _badgeItem(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          color: unlocked ? Colors.amber : Colors.grey[300],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: unlocked ? Colors.black : Colors.grey),
        ),
      ],
    );
  }
}
