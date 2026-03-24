import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PlotsPage extends StatefulWidget {
  const PlotsPage({super.key});

  @override
  State<PlotsPage> createState() => _PlotsPageState();
}

class _PlotsPageState extends State<PlotsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch weather when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherSmartService>().fetchWeatherForLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final bool hasPlots = plots.isNotEmpty;
    final currentWeather = context.watch<WeatherSmartService>().currentWeather;
    final isLoadingWeather = context
        .watch<WeatherSmartService>()
        .isLoadingWeather;
    final weatherError = context.watch<WeatherSmartService>().weatherError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plots'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Weather Widget at the top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildWeatherWidget(
                context,
                currentWeather,
                isLoadingWeather,
                weatherError,
              ),
            ),
            // Plots list
            Expanded(
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
                            onEdit: () => showCreatePlotBottomSheet(
                              context,
                              existingPlot: plot,
                            ),
                            onDelete: () => showDeleteConfirmationDialog(
                              context,
                              plot: plot,
                            ),
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first plot to get started',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePlotBottomSheet(context),
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildWeatherWidget(
    BuildContext context,
    Map<String, dynamic>? weather,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return FarmingCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Fetching weather...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return FarmingCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.orange.shade400,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (weather == null) {
      return FarmingCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.mapPin, color: Colors.grey.shade400, size: 24),
                const SizedBox(height: 8),
                Text(
                  'Enable location to see weather',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Display weather data
    final current = weather['current'] as Map<String, dynamic>;
    final temperature = current['temperature_2m'];
    final humidity = current['relative_humidity_2m'];
    final weatherCode = current['weather_code'];
    final timezone = weather['timezone'] ?? 'UTC';
    final weatherEmoji = WeatherLocationService.getWeatherEmoji(weatherCode);
    final weatherDescription = WeatherLocationService.getWeatherDescription(
      weatherCode,
    );

    return FarmingCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(weatherEmoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$temperature°C',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            weatherDescription,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.droplets,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$humidity%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.globe,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timezone,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
