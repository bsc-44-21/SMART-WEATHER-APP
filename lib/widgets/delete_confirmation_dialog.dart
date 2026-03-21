import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plot.dart';
import '../services/weather_smart_service.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context, {
  required PlotModel plot,
}) async {
  final controller = TextEditingController();
  bool isSaving = false;

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isMatch = controller.text.trim() == plot.name;

          return AlertDialog(
            title: Text('Delete ${plot.name}?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action cannot be undone. To confirm, type the plot name below:',
                ),
                const SizedBox(height: 16),
                Text(
                  plot.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    hintText: 'Type plot name here',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (isMatch && !isSaving)
                    ? () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await context.read<WeatherSmartService>().deletePlot(
                            plot.id,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Plot "${plot.name}" deleted.'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Delete failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete Plot'),
              ),
            ],
          );
        },
      );
    },
  );
}
