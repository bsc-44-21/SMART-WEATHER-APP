import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_smart_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/forecast_widgets.dart';

class PlotDetailsPage extends StatelessWidget {
  final String plotId;

  const PlotDetailsPage({
    super.key,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final plots = weatherService.plots;
    
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
    final weatherData = weatherService.getPlotWeather(plotId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${plot.name} Details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0), // Changed from EdgeInsets.all
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PlotInfoCard(
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
              ),
              const SizedBox(height: 24),
              if (weatherData != null && weatherData['hourly'] != null)
                HourlyForecastWidget(hourlyData: weatherData['hourly']),
              if (weatherData != null && weatherData['hourly'] != null)
                const SizedBox(height: 24),
              if (weatherData != null && weatherData['daily'] != null)
                DailyForecastWidget(dailyData: weatherData['daily']),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
