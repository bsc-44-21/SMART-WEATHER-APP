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
                  // HEADER
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

                  // ACTIVITY INPUT
                  TextField(
                    controller: _activityController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Record activity...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LOG LIST WITH AI ADVICE
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Text('No activities yet'),
                          )
                        : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Activity
                                      Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.checkSquare,
                                            color: AppTheme.primaryAccent,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              log['title'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // Meta
                                      Text(
                                        "Plot: ${log['plot']} | Date: ${log['time']}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // 🔥 AI RESPONSE SECTION
                                      if (log['isGeneratingAdvice'] == true)
                                        Row(
                                          children: const [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text("Generating advice..."),
                                          ],
                                        )
                                      else if ((log['advice'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.smart_toy,
                                                  size: 18,
                                                  color: Colors.green),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  log['advice'],
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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