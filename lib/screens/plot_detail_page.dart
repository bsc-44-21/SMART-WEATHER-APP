import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/plot.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PlotDetailPage extends StatefulWidget {
  final PlotModel initialPlot;

  const PlotDetailPage({super.key, required this.initialPlot});

  @override
  State<PlotDetailPage> createState() => _PlotDetailPageState();
}

class _PlotDetailPageState extends State<PlotDetailPage> {
  late PlotModel _plot;

  @override
  void initState() {
    super.initState();
    _plot = widget.initialPlot;
  }

  void _updatePlotRef() {
    // Attempt to grab the latest plot object from provider
    final plots = context.read<WeatherSmartService>().plots;
    try {
      _plot = plots.firstWhere((p) => p.id == _plot.id);
    } catch (_) {
      // Plot might be deleted, handle securely
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild UI when provider updates
    context.watch<WeatherSmartService>();
    _updatePlotRef();

    final weatherData = context.watch<WeatherSmartService>().getPlotWeather(_plot.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _plot.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit3, color: AppTheme.primaryAccent),
            onPressed: () => showCreatePlotBottomSheet(
              context,
              existingPlot: _plot,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
            onPressed: () => showDeleteConfirmationDialog(
              context,
              plot: _plot,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<WeatherSmartService>().fetchWeatherForPlots();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlotHeaders(),
                const SizedBox(height: 24),
                if (weatherData != null) ...[
                  _buildCurrentWeatherDetails(weatherData['current']),
                  const SizedBox(height: 32),
                  _buildHourlyForecast(weatherData['hourly']),
                  const SizedBox(height: 32),
                  _buildDailyForecast(weatherData['daily']),
                  const SizedBox(height: 32),
                  _buildPlotActivities(),
                  const SizedBox(height: 32),
                ] else ...[
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            "Loading plot data...",
                            style: GoogleFonts.inter(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlotActivities() {
    final allLogs = context.watch<WeatherSmartService>().logs;
    // Filter logs for this specific plot
    // Fallback to name-matching for legacy logs without plotId
    final plotLogs = allLogs.where((log) {
      if (log['plotId'] != null) {
        return log['plotId'] == _plot.id;
      }
      return log['plot'] == _plot.name;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activities",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plotLogs.isNotEmpty)
                Text(
                  "${plotLogs.length} total",
                  style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (plotLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.clipboardList, size: 40, color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Text(
                    "No activities recorded yet",
                    style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plotLogs.length.clamp(0, 5), // Show last 5
              itemBuilder: (context, index) {
                final log = plotLogs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: FarmingCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                       // Log Details could be opened here if needed
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.check, size: 16, color: AppTheme.primaryAccent),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log['title'] ?? '',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                log['time'] ?? '',
                                style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (log['isRecommended'] != null)
                           Icon(
                            log['isRecommended'] == true ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                            size: 16,
                            color: log['isRecommended'] == true ? Colors.green : Colors.orange,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlotHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FarmingCard(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(_plot.cropEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(_plot.cropName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                    Text("Crop", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade200),
                _HeaderItem(icon: LucideIcons.maximize, title: "Size", value: "${_plot.fieldSize} Ha"),
                Container(height: 40, width: 1, color: Colors.grey.shade200),
                _HeaderItem(icon: LucideIcons.calendar, title: "Planted", value: _plot.plantingDate),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.mapPin, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _plot.location,
                    style: GoogleFonts.inter(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherDetails(Map<String, dynamic>? current) {
    if (current == null) return const SizedBox();
    
    final int temp = (current['temperature_2m'] as num).round();
    final int weatherCode = current['weather_code'];
    final String emoji = WeatherLocationService.getWeatherEmoji(weatherCode);
    final String desc = WeatherLocationService.getWeatherDescription(weatherCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Weather",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryAccent,
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "$temp°",
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _WeatherStatBox(
                icon: LucideIcons.wind,
                value: "${current['wind_speed_10m']} km/h",
                label: "Wind",
              ),
              const SizedBox(width: 12),
              _WeatherStatBox(
                icon: LucideIcons.droplets,
                value: "${current['relative_humidity_2m']}%",
                label: "Humidity",
              ),
              const SizedBox(width: 12),
              _WeatherStatBox(
                icon: LucideIcons.cloudRain,
                value: "${current['precipitation']} mm",
                label: "Rain",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(Map<String, dynamic>? hourly) {
    if (hourly == null) return const SizedBox();

    final List<dynamic> times = hourly['time'];
    final List<dynamic> temps = hourly['temperature_2m'];
    final List<dynamic> codes = hourly['weather_code'];
    final List<dynamic> pops = hourly['precipitation_probability'];

    // Find the first index that is near 'now' local time (by parsing Open-Meteo GMT times)
    int startIndex = 0;
    final now = DateTime.now();
    for (int i = 0; i < times.length; i++) {
        final dt = DateTime.parse("${times[i]}Z").toLocal();
        // If this hour block is after 1 hour ago, use it as starting point
        if (dt.isAfter(now.subtract(const Duration(hours: 1)))) {
           startIndex = i;
           break;
        }
    }

    final int count = 24; // next 24 hours
    final int endIndex = (startIndex + count).clamp(0, times.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Next 24 Hours",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: endIndex - startIndex,
            itemBuilder: (context, index) {
              final actualIndex = startIndex + index;
              final dt = DateTime.parse("${times[actualIndex]}Z").toLocal();
              final isNow = index == 0; // First item is 'Now'

              return Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isNow ? AppTheme.primaryAccent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isNow ? 'Now' : DateFormat('ha').format(dt).toLowerCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                        color: isNow ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      WeatherLocationService.getWeatherEmoji(codes[actualIndex]),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(temps[actualIndex] as num).round()}°",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isNow ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    if (pops[actualIndex] > 0)
                      Text(
                        "${pops[actualIndex]}%",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isNow ? Colors.white70 : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDailyForecast(Map<String, dynamic>? daily) {
    if (daily == null) return const SizedBox();

    final List<dynamic> times = daily['time'];
    final List<dynamic> maxTemps = daily['temperature_2m_max'];
    final List<dynamic> minTemps = daily['temperature_2m_min'];
    final List<dynamic> codes = daily['weather_code'];
    final List<dynamic> precipSum = daily['precipitation_sum'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "7-Day Forecast",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: times.length,
              separatorBuilder: (context, _) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final dt = DateTime.parse(times[index]); // Daily time is usually YYYY-MM-DD
                final isToday = index == 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          isToday ? "Today" : DateFormat('EEEE').format(dt),
                          style: GoogleFonts.inter(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        WeatherLocationService.getWeatherEmoji(codes[index]),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      // Precipitation info if any
                      SizedBox(
                        width: 50,
                        child: Text(
                          precipSum[index] > 0.0 ? "${precipSum[index]}mm" : "",
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${(minTemps[index] as num).round()}°",
                              style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 16, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 12),
                            Text(
                              "${(maxTemps[index] as num).round()}°",
                              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _WeatherStatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStatBox({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryAccent),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HeaderItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryAccent),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
        Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
