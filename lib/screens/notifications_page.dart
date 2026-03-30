import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../models/plot.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  List<Widget> _buildNotificationsForWeather(
    Map<String, dynamic>? weather, {
    required String plotName,
    required String cropName,
  }) {
    List<Widget> widgets = [];

    if (weather != null && weather['current'] != null) {
      final current = weather['current'];
      final temp = current['temperature_2m'] as num?;
      final humidity = current['relative_humidity_2m'] as num?;
      final precipitation = current['precipitation'] as num?;

      // Default Messages
      String heavyRainMsg = 'Heavy rain detected. High precipitation may damage crops. Take action immediately.';
      String rainMsg = 'Light to moderate rain expected. Good for your crops, but monitor the situation.';
      String heatMsg = 'Temperature is critically high. Ensure adequate irrigation.';
      String frostMsg = 'Temperature is alarmingly low. Protect sensitive crops from possible frost.';
      String highHumMsg = 'Humidity is high. Be aware of an increased risk of fungal diseases.';
      String lowHumMsg = 'Humidity is very low. Your crops might require additional watering.';
      String optimalMsg = 'Current weather conditions are excellent. Keep up the good work!';

      // Overrides based on crop type
      final crop = cropName.toLowerCase();

      if (crop.contains('tomato')) {
        heavyRainMsg = 'Heavy rain strongly increases the risk of Blight and fruit cracking in Tomatoes. Ensure good drainage.';
        heatMsg = 'Temperatures over 35°C can cause blossom drop in Tomatoes. Consider using shade nets.';
        frostMsg = 'Tomatoes are extremely sensitive to cold. Cover them immediately to prevent frost damage!';
        highHumMsg = 'High humidity strongly increases the risk of Early and Late Blight in Tomatoes. Monitor closely.';
        optimalMsg = 'Perfect conditions for Tomatoes to grow and ripen properly.';
      } else if (crop.contains('maize') || crop.contains('corn')) {
        heavyRainMsg = 'Heavy rain may cause waterlogging and nutrient leaching in your Maize field.';
        heatMsg = 'Extreme heat stresses Maize and can severely affect pollination and kernel set. Maintain soil moisture.';
        frostMsg = 'Frost can severely damage young Maize plants and halt growth.';
        highHumMsg = 'High humidity may encourage Maize Rust or Leaf Blight. Keep an eye on the leaves.';
        optimalMsg = 'Great weather for Maize stalk development and filling out ears.';
      } else if (crop.contains('groundnut') || crop.contains('peanut')) {
        heavyRainMsg = 'Excessive rain can cause groundnut pod rot in the soil and increase Aflatoxin risk.';
        rainMsg = 'Rain is good for pegging, but watch out for waterlogging in your Groundnuts.';
        heatMsg = 'Groundnuts are heat-tolerant, but prolonged extreme temps can reduce pegging efficiency.';
        highHumMsg = 'High humidity increases the chance of Early and Late Leaf Spot in Groundnuts.';
        optimalMsg = 'Warm and balanced conditions! Excellent for Groundnut pod development.';
      } else if (crop.contains('potato')) {
        heavyRainMsg = 'Heavy rain can cause tuber rot and wash away soil from the potato hills.';
        highHumMsg = 'High humidity is a major trigger for Potato Late Blight. Apply preventative measures if needed.';
        optimalMsg = 'Ideal cool and balanced weather for healthy potato tuber growth.';
      } else if (crop.contains('bean')) {
        heavyRainMsg = 'Heavy downpours can damage delicate bean flowers and cause root rot.';
        heatMsg = 'High heat can cause bean flowers to drop off without forming pods.';
        optimalMsg = 'Excellent conditions for flowering and pod development in beans.';
      } else if (crop.contains('tobacco')) {
        heavyRainMsg = 'Heavy rain can cause waterlogging, which Tobacco plants are highly sensitive to.';
        highHumMsg = 'High humidity drastically increases the risk of angular leaf spot and mildew in Tobacco.';
      }

      bool hasAlerts = false;

      if (precipitation != null && precipitation > 10.0) {
        widgets.add(_NotificationCard(
          icon: LucideIcons.alertTriangle,
          title: 'Heavy Rain Alert',
          plotName: plotName,
          cropName: cropName,
          message: heavyRainMsg,
          time: 'Active Now',
          color: const Color(0xFFFFEBEE), // Very light red
          iconColor: Colors.red,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      } else if (precipitation != null && precipitation > 0) {
        widgets.add(_NotificationCard(
          icon: LucideIcons.cloudRain,
          title: 'Rain Alert',
          plotName: plotName,
          cropName: cropName,
          message: rainMsg,
          time: 'Active Now',
          color: const Color(0xFFE8EAF6), // Very light indigo
          iconColor: Colors.indigo,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      }

      if (temp != null && temp > 35) {
        widgets.add(_NotificationCard(
          icon: Icons.thermostat,
          title: 'Extreme Heat',
          plotName: plotName,
          cropName: cropName,
          message: heatMsg,
          time: 'Active Now',
          color: const Color(0xFFFFF3E0),
          iconColor: Colors.orange,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      } else if (temp != null && temp < 5) {
        widgets.add(_NotificationCard(
          icon: Icons.ac_unit,
          title: 'Frost Warning',
          plotName: plotName,
          cropName: cropName,
          message: frostMsg,
          time: 'Active Now',
          color: const Color(0xFFE3F2FD),
          iconColor: Colors.blue,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      }
      
      if (humidity != null && humidity > 85) {
        widgets.add(_NotificationCard(
          icon: Icons.water_drop,
          title: 'High Humidity Risk',
          plotName: plotName,
          cropName: cropName,
          message: highHumMsg,
          time: 'Active Now',
          color: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      } else if (humidity != null && humidity < 30) {
        widgets.add(_NotificationCard(
          icon: Icons.water_drop_outlined,
          title: 'Low Humidity Alert',
          plotName: plotName,
          cropName: cropName,
          message: lowHumMsg,
          time: 'Active Now',
          color: const Color(0xFFFFF9DB),
          iconColor: Colors.amber,
        ));
        widgets.add(const SizedBox(height: 16));
        hasAlerts = true;
      }

      // If weather is normal and no notifications generated
      if (!hasAlerts) {
        widgets.add(_NotificationCard(
          icon: LucideIcons.leaf,
          title: 'Optimal Weather',
          plotName: plotName,
          cropName: cropName,
          message: optimalMsg,
          time: 'Active Now',
          color: Colors.white,
          iconColor: Colors.green,
        ));
        widgets.add(const SizedBox(height: 16));
      }
    } else {
      widgets.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No weather data yet for $plotName.',
              style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final isLoading = weatherService.isLoadingWeather;
    final plots = weatherService.plots;

    List<Widget> notificationWidgets = [];
    int alertCount = 0;

    if (isLoading) {
      notificationWidgets.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      if (plots.isEmpty) {
        notificationWidgets.addAll(
          _buildNotificationsForWeather(
            weatherService.currentWeather,
            plotName: "Current Location",
            cropName: "General"
          )
        );
      } else {
        for (var plot in plots) {
          final plotWeather = weatherService.getPlotWeather(plot.id);
          final pName = plot.name.isNotEmpty ? plot.name : "Unnamed Plot";
          final cName = plot.cropName.isNotEmpty ? plot.cropName : "Crop";
          
          final cards = _buildNotificationsForWeather(
            plotWeather,
            plotName: pName,
            cropName: cName,
          );
          notificationWidgets.addAll(cards);
          
          // Count non-optimal notifications as alerts
          alertCount += cards.where((w) {
            if (w is _NotificationCard) {
              return !w.title.contains('Optimal');
            }
            return false;
          }).length;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryAccent),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  TextButton(
                    onPressed: () {
                      // Logic to clear could be added here
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryAccent,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$alertCount Active Alerts',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notifications List
              Expanded(
                child: notificationWidgets.isEmpty && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.bellOff, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Everything is clear!',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: notificationWidgets,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final Color iconColor;
  final String? plotName;
  final String? cropName;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    required this.iconColor,
    this.plotName,
    this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    final isOptimal = title.contains('Optimal');
    final accentColor = isOptimal ? Colors.green : iconColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 6,
            color: accentColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (plotName != null || cropName != null) ...[
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (plotName != null)
                            _buildInfoChip(LucideIcons.mapPin, plotName!, accentColor),
                          if (cropName != null) ...[
                            const SizedBox(width: 8),
                            _buildInfoChip(LucideIcons.leaf, cropName!, accentColor),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
