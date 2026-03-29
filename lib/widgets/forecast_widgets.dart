import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/weather_location_service.dart';
import '../core/theme.dart';

class HourlyForecastWidget extends StatelessWidget {
  final Map<String, dynamic> hourlyData;

  const HourlyForecastWidget({super.key, required this.hourlyData});

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 10, color: AppTheme.primaryAccent),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    final List<dynamic>? times = hourlyData['time'];
    if (times == null) return const SizedBox.shrink();

    final List<dynamic> temps = hourlyData['temperature_2m'];
    final List<dynamic> precip = hourlyData['precipitation'];
    final List<dynamic> codes = hourlyData['weather_code'];
    final List<dynamic> wind = hourlyData['wind_speed_10m'];
    final List<dynamic> humidity = hourlyData['relative_humidity_2m'];

    final now = DateTime.now();
    int startIndex = 0;
    for (int i = 0; i < times.length; i++) {
        final dt = DateTime.parse(times[i]);
        if (dt.isAfter(now.subtract(const Duration(hours: 1)))) {
            startIndex = i;
            break;
        }
    }

    final itemCount = (times.length - startIndex).clamp(0, 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '24-Hour Forecast',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final i = startIndex + index;
              final dt = DateTime.parse(times[i]);
              final timeStr = DateFormat('j').format(dt);
              final emoji = WeatherLocationService.getWeatherEmoji(codes[i]);
              final t = temps[i];
              final p = precip[i];
              final w = wind[i];
              final h = humidity[i];

              return Container(
                width: 85,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(timeStr, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    const SizedBox(height: 6),
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text('${t.round()}°', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _buildIconLabel(LucideIcons.droplets, '${p}mm'),
                    const SizedBox(height: 4),
                    _buildIconLabel(LucideIcons.wind, '${w.round()}km'),
                    const SizedBox(height: 4),
                    _buildIconLabel(LucideIcons.cloudRain, '${h}%'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DailyForecastWidget extends StatelessWidget {
  final Map<String, dynamic> dailyData;

  const DailyForecastWidget({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) return const SizedBox.shrink();

    final List<dynamic>? times = dailyData['time'];
    if (times == null) return const SizedBox.shrink();
    
    final List<dynamic> maxTemps = dailyData['temperature_2m_max'];
    final List<dynamic> minTemps = dailyData['temperature_2m_min'];
    final List<dynamic> codes = dailyData['weather_code'];
    final List<dynamic> precip = dailyData['precipitation_sum'];
    final List<dynamic> wind = dailyData['wind_speed_10m_max'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '7-Day Forecast',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final dt = DateTime.parse(times[index]);
              final dayStr = index == 0 ? 'Today' : DateFormat('EEEE').format(dt);
              final emoji = WeatherLocationService.getWeatherEmoji(codes[index]);
              
              return Row(
                children: [
                  Expanded(flex: 3, child: Text(dayStr, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey.shade800))),
                  Expanded(
                    flex: 1, 
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(LucideIcons.droplets, size: 12, color: AppTheme.primaryAccent),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 35,
                          child: Text('${precip[index]}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                        ),
                        Icon(LucideIcons.wind, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 25,
                          child: Text('${wind[index].round()}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                        ),
                        Text(
                          '${minTemps[index].round()}°',
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
                        ),
                        Text(
                          ' / ${maxTemps[index].round()}°',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
