import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// 主题选择对话框
class ThemeSelectionDialog extends StatefulWidget {
  final ThemeModeOption currentMode;

  const ThemeSelectionDialog({
    super.key,
    required this.currentMode,
  });

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  late ThemeModeOption _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '选择主题',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            icon: Icons.brightness_auto,
            title: '跟随系统',
            subtitle: '根据系统设置自动切换',
            value: ThemeModeOption.system,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            icon: Icons.wb_sunny,
            title: '浅色模式',
            subtitle: '使用明亮的浅色主题',
            value: ThemeModeOption.light,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            icon: Icons.dark_mode,
            title: '深色模式',
            subtitle: '使用暗色主题保护眼睛',
            value: ThemeModeOption.dark,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            ThemeService().setTheme(_selectedMode);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('应用'),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeModeOption value,
  }) {
    final isSelected = _selectedMode == value;
    final color = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题切换按钮组件（可嵌入到设置页面）
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final currentMode = themeService.currentMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getModeIcon(currentMode),
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: const Text(
        '主题模式',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(_getModeText(currentMode)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ThemeSelectionDialog(currentMode: currentMode),
        );
      },
    );
  }

  IconData _getModeIcon(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return Icons.wb_sunny;
      case ThemeModeOption.dark:
        return Icons.dark_mode;
      case ThemeModeOption.system:
      default:
        return Icons.brightness_auto;
    }
  }

  String _getModeText(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return '浅色模式';
      case ThemeModeOption.dark:
        return '深色模式';
      case ThemeModeOption.system:
      default:
        return '跟随系统';
    }
  }
}
