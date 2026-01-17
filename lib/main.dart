import 'package:flutter/material.dart';
import 'main_container.dart';
import 'background_service.dart';
import 'privacy_policy_dialog.dart';
import 'step_counter_service.dart';
import 'services/theme_service.dart';
import 'services/onboarding_service.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  await ThemeService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    await ThemeService().initialize();
    final mode = ThemeService().currentMode;
    setState(() {
      _themeMode = ThemeService().getThemeMode(mode);
    });

    // 监听主题变化
    ThemeService().themeStream.listen((mode) {
      setState(() {
        _themeMode = ThemeService().getThemeMode(mode);
      });
    });
  }

  void updateTheme(ThemeMode mode) {
    ThemeModeOption option;
    switch (mode) {
      case ThemeMode.light:
        option = ThemeModeOption.light;
        break;
      case ThemeMode.dark:
        option = ThemeModeOption.dark;
        break;
      default:
        option = ThemeModeOption.system;
    }
    ThemeService().setTheme(option);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepCounter',
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
      home: PrivacyPolicyWrapper(onThemeChanged: updateTheme),
    );
  }
}

class PrivacyPolicyWrapper extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const PrivacyPolicyWrapper({super.key, required this.onThemeChanged});

  @override
  _PrivacyPolicyWrapperState createState() => _PrivacyPolicyWrapperState();
}

class _PrivacyPolicyWrapperState extends State<PrivacyPolicyWrapper> {
  bool _privacyAccepted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrivacy();
    });
  }

  Future<void> _checkPrivacy() async {
    final accepted = await PrivacyPolicyDialog.showFirstLaunchDialog(context);
    if (accepted) {
      final permissionAccepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.security, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('权限申请说明'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '为了为您提供准确的计步服务，我们需要申请以下权限：',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  Icons.directions_run,
                  '健身运动权限（身体传感器）',
                  '用于读取您的步数数据，实现实时计步功能',
                ),
                const SizedBox(height: 12),
                _buildPermissionItem(
                  Icons.notifications,
                  '通知权限',
                  '用于在后台持续运行时，向您展示计步状态',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '您的数据仅存储在本地设备，不会上传到任何服务器',
                          style:
                              TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('同意授权'),
            ),
          ],
        ),
      );

      if (permissionAccepted ?? false) {
        // 检查是否需要显示引导页面
        final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
        if (mounted) {
          setState(() {
            _privacyAccepted = true;
            _loading = false;
          });
          
          // 如果引导未完成，稍后显示引导页面
          if (!onboardingCompleted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                );
              }
            });
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).popUntil((route) => false);
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).popUntil((route) => false);
      }
    }
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (!_privacyAccepted) {
      return const Scaffold(
        body: Center(
          child: Text('应用即将退出'),
        ),
      );
    }
    return const MainContainer();
  }
}
