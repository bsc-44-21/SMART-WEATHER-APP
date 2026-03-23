import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PlotsPage extends StatelessWidget {
  const PlotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final bool hasPlots = plots.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plots'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: hasPlots
            ? ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: plots.length,
                itemBuilder: (context, index) {
                  final plot = plots[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PlotInfoCard(
                      plot: plot,
                      onEdit: () => showCreatePlotBottomSheet(context, existingPlot: plot),
                      onDelete: () => showDeleteConfirmationDialog(context, plot: plot),
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.map,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No plots yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first plot to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePlotBottomSheet(context),
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}