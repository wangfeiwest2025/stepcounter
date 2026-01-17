import 'package:flutter/material.dart';
import 'step_counter_screen.dart';
import 'stats_screen.dart';
import 'health_screen.dart';
import 'profile_screen.dart';
import 'widgets/feature_tour.dart';
import 'services/onboarding_service.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // 导览需要的GlobalKey
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _healthKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 延迟显示导览，确保页面已渲染完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTourIfNeeded();
    });
  }

  Future<void> _showTourIfNeeded() async {
    final completed = await OnboardingService.isOnboardingCompleted();
    if (!completed && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        FeatureTour.show(
          homeKey: _homeKey,
          statsKey: _statsKey,
          healthKey: _healthKey,
          profileKey: _profileKey,
          onTourEnd: () {},
        );
      }
    }
  }

  final List<Widget> _pages = [
    const StepCounterScreen(),
    const StatsScreen(),
    const HealthScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            key: _homeKey,
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: '主页',
          ),
          NavigationDestination(
            key: _statsKey,
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '分析',
          ),
          NavigationDestination(
            key: _healthKey,
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: '健康',
          ),
          NavigationDestination(
            key: _profileKey,
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
