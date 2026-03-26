import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import 'home_page.dart';
import 'plots_page.dart';
import 'detect_page.dart';
import 'log_page.dart';
import 'profile_settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    PlotsPage(),
    DetectPage(),
    LogPage(),
    ProfileSettingsPage(),
  ];
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
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
          type: BottomNavigationBarType.fixed, // Needed when >3 items
          items: [
            _buildNavItem(LucideIcons.layoutGrid, 'HOME', 0),
            _buildNavItem(LucideIcons.map, 'PLOTS', 1),
            _buildNavItem(LucideIcons.sparkles, 'DETECT', 2),
            _buildNavItem(LucideIcons.clipboardList, 'LOG', 3),
            _buildNavItem(LucideIcons.user, 'PROFILE', 4),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedItemColor: AppTheme.primaryAccent,
          unselectedItemColor: AppTheme.textMuted,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
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