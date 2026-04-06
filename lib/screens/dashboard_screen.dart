import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/navigation_service.dart';
import 'home_page.dart';
import 'plots_page.dart';
import 'detect_page.dart';
import 'log_page.dart';
import 'profile_settings_page.dart';

import '../services/weather_smart_service.dart';
import '../services/notification_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _milestonesScheduled = false;

  static const List<Widget> _pages = [
    HomePage(),
    PlotsPage(),
    DetectPage(),
    LogPage(),
    ProfileSettingsPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_milestonesScheduled) {
      final weatherService = context.watch<WeatherSmartService>();
      if (weatherService.plots.isNotEmpty && weatherService.logs.isNotEmpty) {
        final notifService = context.read<NotificationService>();
        for (var plot in weatherService.plots) {
          final plotWeather = weatherService.getPlotWeather(plot.id);
          notifService.schedulePlotMilestones(plot, weatherService.logs, plotWeather: plotWeather);
        }
        _milestonesScheduled = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = context.watch<NavigationService>();
    final selectedIndex = navigationService.selectedIndex;

    return Scaffold(
      body: SafeArea(
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(context, LucideIcons.layoutGrid, 'HOME', 0, selectedIndex),
            _buildNavItem(context, LucideIcons.map, 'PLOTS', 1, selectedIndex),
            _buildNavItem(context, LucideIcons.sparkles, 'DETECT', 2, selectedIndex),
            _buildNavItem(context, LucideIcons.clipboardList, 'LOG', 3, selectedIndex),
            _buildNavItem(context, LucideIcons.user, 'PROFILE', 4, selectedIndex),
          ],
          currentIndex: selectedIndex,
          onTap: (index) => navigationService.setIndex(index),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedItemColor: AppTheme.primaryAccent,
          unselectedItemColor: AppTheme.textMuted,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      BuildContext context, IconData icon, String label, int index, int selectedIndex) {
    final bool isSelected = selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.background : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }
}