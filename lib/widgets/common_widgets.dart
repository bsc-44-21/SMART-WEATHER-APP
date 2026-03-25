import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../core/theme.dart';
import '../models/plot.dart';
import 'package:intl/intl.dart';

class FarmingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Decoration? decoration;

  const FarmingCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration ?? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(32.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const AppLogo({super.key, this.size = 64, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.primaryAccent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            LucideIcons.sprout,
            color: backgroundColor != null ? AppTheme.primaryAccent : Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

class PlotInfoCard extends StatelessWidget {
  final PlotModel plot;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlotInfoCard({
    super.key,
    required this.plot,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final weatherData = context.watch<WeatherSmartService>().getPlotWeather(plot.id);
    final current = weatherData?['current'];
    final weatherCode = current?['weather_code'] ?? 0;
    
    // Dynamic Gradient based on weather
    final Decoration cardDecoration = _getWeatherDecoration(context, weatherCode);

    return FarmingCard(
      padding: EdgeInsets.zero,
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCropIcon(),
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
                              plot.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          _buildActionButtons(context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildPlotDetails(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Weather Section
          if (weatherData != null) _buildWeatherGrid(context, current, weatherCode),
          
          // Footer Status
          _buildStatusFooter(context, weatherData),
        ],
      ),
    );
  }

  Decoration _getWeatherDecoration(BuildContext context, int weatherCode) {
    List<Color> colors;
    if (weatherCode == 0) {
      colors = [const Color(0xFF56AB2F), const Color(0xFFA8E063)]; // Sunny/Green
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      colors = [const Color(0xFF2193B0), const Color(0xFF6DD5ED)]; // Cloudy/Blue
    } else if (weatherCode >= 51 && weatherCode <= 65) {
      colors = [const Color(0xFF4B6CB7), const Color(0xFF182848)]; // Rainy/Dark Blue
    } else {
      colors = [AppTheme.primaryAccent, const Color(0xFF66BB6A)]; // Default
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: colors[0].withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildCropIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(LucideIcons.sprout, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _iconButton(LucideIcons.edit, onEdit, 'Edit'),
        const SizedBox(width: 8),
        _iconButton(LucideIcons.trash2, onDelete, 'Delete', isDelete: true),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onPressed, String tooltip, {bool isDelete = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: isDelete ? Colors.red.shade100 : Colors.white,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildPlotDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow(LucideIcons.mapPin, plot.location),
        const SizedBox(height: 4),
        Row(
          children: [
            _detailRow(LucideIcons.calendar, plot.plantingDate),
            const SizedBox(width: 12),
            _detailRow(LucideIcons.ruler, '${plot.fieldSize} Ha'),
          ],
        ),
        const SizedBox(height: 4),
        _detailRow(LucideIcons.leaf, plot.cropName),
      ],
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWeatherGrid(BuildContext context, dynamic current, int weatherCode) {
    final temp = current['temperature_2m'];
    final humidity = current['relative_humidity_2m'];
    final precipitation = current['precipitation'] ?? current['rain'] ?? 0;
    final wind = current['wind_speed_10m'];
    final weatherEmoji = WeatherLocationService.getWeatherEmoji(weatherCode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(weatherEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$temp°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    WeatherLocationService.getWeatherDescription(weatherCode),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _weatherMetric('💧', '$humidity%'),
              const SizedBox(height: 4),
              _weatherMetric('🌧️', '${precipitation}mm'),
              const SizedBox(height: 4),
              _weatherMetric('💨', '${wind}km/h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherMetric(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusFooter(BuildContext context, Map<String, dynamic>? weatherData) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 4, backgroundColor: Colors.white),
                const SizedBox(width: 8),
                Text(
                  plot.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            'Updated ${weatherData?['fetched_at'] != null ? DateFormat('h:mm a').format(DateTime.parse(weatherData!['fetched_at'])) : 'just now'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
