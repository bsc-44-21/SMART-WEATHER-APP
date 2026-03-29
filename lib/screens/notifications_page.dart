import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
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
        // Fallback to current location if user has no plots
        notificationWidgets.addAll(
          _buildNotificationsForWeather(
            weatherService.currentWeather,
            plotName: "Current Location",
            cropName: "General"
          )
        );
      } else {
        // Generate notifications specifically targeting each plot
        for (var plot in plots) {
          final plotWeather = weatherService.getPlotWeather(plot.id);
          final pName = plot.name.isNotEmpty ? plot.name : "Unnamed Plot";
          final cName = plot.cropName.isNotEmpty ? plot.cropName : "Crop";
          
          notificationWidgets.addAll(
            _buildNotificationsForWeather(
              plotWeather,
              plotName: pName,
              cropName: cName,
            )
          );
        }
      }
    }

    // Add back button at the end
    notificationWidgets.add(const SizedBox(height: 8));
    notificationWidgets.add(
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Back to Settings',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const AppLogo(size: 40, backgroundColor: Colors.white),
                  const SizedBox(width: 16),
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Weather alerts customized for your plots:',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Notifications List
              Expanded(
                child: ListView(
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: iconColor == Colors.black54 ? AppTheme.textPrimary : iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (plotName != null || cropName != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (plotName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: iconColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.mapPin, size: 12, color: iconColor),
                              const SizedBox(width: 4),
                              Text(
                                plotName!,
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (cropName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: iconColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.leaf, size: 12, color: iconColor),
                              const SizedBox(width: 4),
                              Text(
                                cropName!,
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
