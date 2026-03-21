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