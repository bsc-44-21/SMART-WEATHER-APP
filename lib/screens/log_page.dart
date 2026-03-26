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
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    _plotController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _addActivity(BuildContext context) {
    final activity = _activityController.text.trim();
    final plot = _plotController.text.trim();
    final date = _dateController.text.trim();

    if (activity.isEmpty || plot.isEmpty || date.isEmpty) return;

    context.read<WeatherSmartService>().addLog(
      activity,
      plot: plot,
      date: date,
    );

    _activityController.clear();
    _plotController.clear();
    _dateController.clear();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
                  // HEADER (NO SETTINGS ICON)
                  Row(
                    children: [
                      const AppLogo(
                        size: 40,
                        backgroundColor: Color(0xFFE3F2FD),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Activity Log',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // PLOT INPUT
                  TextField(
                    controller: _plotController,
                    decoration: InputDecoration(
                      hintText: 'Enter plot name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DATE INPUT
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        _dateController.text =
                            "${picked.day}/${picked.month}/${picked.year}";
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // ACTIVITY INPUT (EXPANDS)
                  TextField(
                    controller: _activityController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Record activity...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SEND BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addActivity(context),
                      icon: const Icon(Icons.send),
                      label: const Text("Send"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LOG LIST
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.clipboardList,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Ready to record',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Log your farm activities to keep an accurate history.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];

                              return ListTile(
                                leading: const Icon(
                                  LucideIcons.checkSquare,
                                  color: AppTheme.primaryAccent,
                                ),
                                title: Text(log['title'] ?? ''),
                                subtitle: Text(
                                  "Plot: ${log['plot']} | Date: ${log['time']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
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
