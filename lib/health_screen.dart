import 'package:flutter/material.dart';
import 'step_counter_service.dart';
import 'widgets/loading_skeleton.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final StepCounterService _service = StepCounterService();
  int _waterCount = 0;
  bool _sedentaryEnabled = false;
  int _sedentaryInterval = 60;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final water = await _service.getTodayWater();
    final enabled = await _service.isSedentaryReminderEnabled();
    final interval = await _service.getSedentaryInterval();
    if (mounted) {
      setState(() {
        _waterCount = water;
        _sedentaryEnabled = enabled;
        _sedentaryInterval = interval;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康生态'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWaterCard(),
          const SizedBox(height: 20),
          _buildSedentaryCard(),
          const SizedBox(height: 20),
          _buildHealthyTips(),
        ],
      ),
    );
  }

  Widget _buildWaterCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_drink, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Text(
                  '今日饮水',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWaterButton(Icons.remove, () async {
                  if (_waterCount > 0) {
                    await _service.addWater(-1);
                    _loadData();
                  }
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        '$_waterCount',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const Text('杯 (约250ml/杯)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                _buildWaterButton(Icons.add, () async {
                  await _service.addWater(1);
                  _loadData();
                }),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_waterCount / 8).clamp(0.0, 1.0),
              backgroundColor: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            const Text('目标: 8杯水', style: TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blue),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSedentaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('久坐提醒', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('持续未走动自动发送通知'),
              value: _sedentaryEnabled,
              secondary: Icon(Icons.timer, color: _sedentaryEnabled ? Colors.orange : Colors.grey),
              onChanged: (val) async {
                await _service.setSedentaryReminderEnabled(val);
                _loadData();
              },
            ),
            if (_sedentaryEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('提醒间隔'),
                trailing: DropdownButton<int>(
                  value: _sedentaryInterval,
                  items: [30, 45, 60, 90, 120].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value 分钟'),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      await _service.setSedentaryInterval(val);
                      _loadData();
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthyTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('健康小贴士', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          _tipItem('步行是提高心肺功能最简单的方式。'),
          _tipItem('建议每坐一小时起身活动 5 分钟。'),
          _tipItem('适量饮水能显著改善新陈代谢。'),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.green[800], fontSize: 13))),
        ],
      ),
    );
  }
}
