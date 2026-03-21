import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});
   @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 32),
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSettingsSection([
            _SettingsTile(icon: LucideIcons.bell, title: 'Notifications', onTap: () {}),
            _SettingsTile(icon: LucideIcons.globe, title: 'Language', subtitle: 'English',
            onTap: () {}),
            _SettingsTile(
              icon: LucideIcons.moon, 
              title: 'Dark Mode', 
              isSwitch: true, 
              switchValue: context.watch<WeatherSmartService>().isDarkMode, 
              onChanged: (v) {
                context.read<WeatherSmartService>().toggleDarkMode(v);
              }
            ),
          ]),
          const SizedBox(height: 32),
          Text('Support', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSettingsSection([
            _SettingsTile(icon: LucideIcons.helpCircle, title: 'Help Center', onTap: () {}),
            _SettingsTile(icon: LucideIcons.fileText, title: 'Terms of Service', onTap: () {}),
            _SettingsTile(icon: LucideIcons.shield, title: 'Privacy Policy', onTap: () {}),
          ]),
           const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                foregroundColor: Colors.red,
              ),