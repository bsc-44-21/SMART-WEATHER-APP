import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_smart_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PlotDetailsPage extends StatelessWidget {
  final String plotId;

  const PlotDetailsPage({
    super.key,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    
    final plotIndex = plots.indexWhere((p) => p.id == plotId);
    if (plotIndex == -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
           Navigator.of(context).pop();
        }
      });
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final plot = plots[plotIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${plot.name} Details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlotInfoCard(
                plot: plot,
                onEdit: () => showCreatePlotBottomSheet(
                  context,
                  existingPlot: plot,
                ),
                onDelete: () => showDeleteConfirmationDialog(
                  context,
                  plot: plot,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
