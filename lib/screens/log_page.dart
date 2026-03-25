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
                      Color(0xFFE3F2FD)),
                      const SizedBox(width: 16),
                      Text('Activity Log', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _activityController,
                          decoration: InputDecoration(
                            hintText: 'Record an activity (e.g., Apple Harvest)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                          onSubmitted: (_) => _addActivity(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _addActivity(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.plus, color: Colors.white), 
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.clipboardList, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 24),
                                Text('Ready to record', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  'Log your farm activities to keep an accurate history.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return ListTile(
                                leading: const Icon(LucideIcons.checkSquare, color: AppTheme.primaryAccent),
                                title: Text(log['title'] ?? ''),
                                subtitle: Text(log['time'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
