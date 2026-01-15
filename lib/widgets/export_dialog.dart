import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../step_counter_service.dart';
import '../services/gameification_service.dart';
import '../services/exercise_tracking_service.dart';
import '../services/haptic_service.dart';

/// 数据导出对话框
class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _exportFormat = 'csv';
  bool _exporting = false;
  int _selectedDataType = 0; // 0=所有数据, 1=仅步数, 2=仅运动记录

  final List<Map<String, dynamic>> _exportOptions = [
    {'icon': Icons.data_object, 'title': '导出所有数据', 'subtitle': '包含步数、成就、运动记录', 'value': 0},
    {'icon': Icons.directions_walk, 'title': '仅导出步数数据', 'subtitle': '最近30天的步数记录', 'value': 1},
    {'icon': Icons.fitness_center, 'title': '仅导出运动记录', 'subtitle': '历史运动会话详情', 'value': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.file_download,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '导出数据',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 数据类型选择
          Column(
            children: _exportOptions.map((option) => _buildExportOption(
              icon: option['icon'],
              title: option['title'],
              subtitle: option['subtitle'],
              value: option['value'],
            )).toList(),
          ),
          const SizedBox(height: 20),
          
          // 格式选择
          Row(
            children: [
              _buildFormatButton('CSV', Icons.table_chart, _exportFormat == 'csv'),
              const SizedBox(width: 12),
              _buildFormatButton('JSON', Icons.code, _exportFormat == 'json'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _exporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _exporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('导出'),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
  }) {
    final isSelected = _selectedDataType == value;
    final color = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDataType = value;
            });
            HapticService().light();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatButton(String text, IconData icon, bool isSelected) {
    final color = Theme.of(context).primaryColor;
    final expanded = isSelected;
    
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _exportFormat = text.toLowerCase();
            });
            HapticService().light();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _exporting = true;
    });

    HapticService().medium();

    try {
      String content;
      String fileName;
      String mimeType;

      final stepService = StepCounterService();
      final gameService = GameificationService();
      final exerciseService = ExerciseTrackingService();

      if (_exportFormat == 'csv') {
        content = await _generateCSV(stepService, gameService, exerciseService);
        fileName = 'stepcounter_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
        mimeType = 'text/csv';
      } else {
        content = await _generateJSON(stepService, gameService, exerciseService);
        fileName = 'stepcounter_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
        mimeType = 'application/json';
      }

      // 创建临时文件
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      // 使用Share Plus分享
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: '我的步数统计数据 - 导出时间: ${DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now())}',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ 数据导出成功！'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<String> _generateCSV(StepCounterService stepService, GameificationService gameService, ExerciseTrackingService exerciseService) async {
    final now = DateTime.now();
    final sb = StringBuffer();

    // 根据选择的数据类型生成内容
    if (_selectedDataType == 0 || _selectedDataType == 1) {
      // 导出步数数据
      sb.writeln('=== 步数统计 ===');
      sb.writeln('日期,步数,卡路里(估算),距离(km,估算)');
      final recentSteps = stepService.getRecentDaysSteps(30);
      for (int i = 29; i >= 0; i--) {
        final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
        final steps = recentSteps[date] ?? 0;
        final calories = (steps * 0.04).toStringAsFixed(2);
        final distance = (steps * 0.7 / 1000).toStringAsFixed(3);
        sb.writeln('$date,$steps,$calories,$distance');
      }
      sb.writeln();
    }

    if (_selectedDataType == 0 || _selectedDataType == 2) {
      // 导出运动记录
      sb.writeln('=== 运动记录 ===');
      sb.writeln('开始时间,运动类型,步数,距离(km),卡路里,时长(分钟)');
      // 这里可以添加运动记录的导出
      sb.writeln('(运动记录导出功能即将推出)');
      sb.writeln();
    }

    if (_selectedDataType == 0) {
      // 导出成就统计
      sb.writeln('=== 成就统计 ===');
      sb.writeln('已解锁成就,总成就数');
      sb.writeln('${gameService.unlockedAchievementsCount},${gameService.totalAchievementsCount}');
      sb.writeln();

      // 导出用户等级
      final level = gameService.userLevel;
      if (level != null) {
        sb.writeln('=== 用户等级 ===');
        sb.writeln('等级,经验值,下一级所需');
        sb.writeln('${level.level},${level.currentExp},${level.expToNextLevel}');
      }
    }

    sb.writeln();
    sb.writeln('=== 导出信息 ===');
    sb.writeln('导出时间,${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
    sb.writeln('应用版本,1.0.0');

    return sb.toString();
  }

  Future<String> _generateJSON(StepCounterService stepService, GameificationService gameService, ExerciseTrackingService exerciseService) async {
    final now = DateTime.now();
    final data = <String, dynamic>{};

    data['exportInfo'] = {
      'exportTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      'appVersion': '1.0.0',
    };

    if (_selectedDataType == 0 || _selectedDataType == 1) {
      // 步数数据
      final stepsData = <Map<String, dynamic>>[];
      final recentSteps = stepService.getRecentDaysSteps(30);
      for (int i = 29; i >= 0; i--) {
        final date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
        final steps = recentSteps[date] ?? 0;
        stepsData.add({
          'date': date,
          'steps': steps,
          'calories': double.parse((steps * 0.04).toStringAsFixed(2)),
          'distance': double.parse((steps * 0.7 / 1000).toStringAsFixed(3)),
        });
      }
      data['stepsData'] = stepsData;
    }

    if (_selectedDataType == 0 || _selectedDataType == 2) {
      // 运动记录
      data['exerciseRecords'] = [];
    }

    if (_selectedDataType == 0) {
      // 成就统计
      data['achievements'] = {
        'unlocked': gameService.unlockedAchievementsCount,
        'total': gameService.totalAchievementsCount,
      };

      // 用户等级
      final level = gameService.userLevel;
      if (level != null) {
        data['userLevel'] = {
          'level': level.level,
          'title': level.title,
          'currentExp': level.currentExp,
          'expToNextLevel': level.expToNextLevel,
        };
      }
    }

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

/// 显示导出对话框
void showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ExportDialog(),
  );
}
