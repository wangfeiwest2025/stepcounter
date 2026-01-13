import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'step_counter_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StepCounterService _service = StepCounterService();
  int _weeklyAverage = 0;
  int _monthlyAverage = 0;
  String _selectedRange = '周'; // '周' or '月'

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final weeklyAvg = await _service.getWeeklyAverage();
    final monthlyAvg = await _service.getMonthlyAverage();
    if (mounted) {
      setState(() {
        _weeklyAverage = weeklyAvg;
        _monthlyAverage = monthlyAvg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              // Simple CSV export logic (just printing to console or showing snackbar for now)
              final csv = await _service.exportDataAsCSV();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('数据已导出至本地缓存 (CSV)')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleButtons(),
            const SizedBox(height: 20),
            _buildChartCard(),
            const SizedBox(height: 20),
            _buildAveragesCard(),
            const SizedBox(height: 20),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Center(
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: '周', label: Text('最近7天')),
          ButtonSegment(value: '月', label: Text('最近30天')),
        ],
        selected: {_selectedRange},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedRange = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildChartCard() {
    final days = _selectedRange == '周' ? 7 : 30;
    final recentSteps = _service.getRecentDaysSteps(days);
    
    final barGroups = recentSteps.entries.map((entry) {
      final index = recentSteps.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: days == 7 ? 16 : 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '步数趋势',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 15000,
                  barGroups: barGroups,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: _selectedRange == '周',
                        getTitlesWidget: (value, meta) {
                          final dates = recentSteps.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < dates.length) {
                             final date = DateFormat('MM/dd').format(DateFormat('yyyy-MM-dd').parse(dates[value.toInt()]));
                             return Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: Text(date, style: const TextStyle(fontSize: 10)),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragesCard() {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat('周平均', '$_weeklyAverage', Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSimpleStat('月平均', '$_monthlyAverage', Colors.green),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const Text('步', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final recentSteps = _service.getRecentDaysSteps(30).entries.toList().reversed.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '历史记录 (最近30天)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSteps.length,
          itemBuilder: (context, index) {
            final entry = recentSteps[index];
            final date = entry.key;
            final steps = entry.value;
            final isToday = date == DateFormat('yyyy-MM-dd').format(DateTime.now());
            
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: isToday ? Colors.blue : Colors.grey[200],
                child: Icon(Icons.directions_walk, size: 20, color: isToday ? Colors.white : Colors.grey),
              ),
              title: Text(isToday ? '今日' : date),
              trailing: Text('$steps 步', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('约 ${(steps * 0.7 / 1000).toStringAsFixed(2)} km'),
            );
          },
        ),
      ],
    );
  }
}
