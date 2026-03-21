import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final TextEditingController _activityController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  void _addActivity(BuildContext context) {
    if (_activityController.text.trim().isEmpty) return;
    context.read<WeatherSmartService>().addLog(_activityController.text.trim());
    _activityController.clear();
    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();
  }
   @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final logs = context.watch<WeatherSmartService>().logs;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (plots.isNotEmpty)
            PlotInfoCard(
              plot: plots[0],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: FarmingCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.settings, size: 20),
                      const SizedBox(width: 16),
                      const AppLogo(size: 40, backgroundColor: 