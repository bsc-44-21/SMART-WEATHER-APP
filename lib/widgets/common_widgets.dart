import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final fetchedAt = weatherData?['fetched_at'];
    final current = weatherData?['current'] as Map<String, dynamic>?;

    return FarmingCard(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone 1: Identity & Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(LucideIcons.sprout, color: AppTheme.primaryAccent, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            plot.cropName.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plot.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Options Menu
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                  splashColor: AppTheme.primaryAccent.withOpacity(0.1),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(LucideIcons.moreVertical, color: Colors.grey.shade400, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.edit3, size: 16, color: AppTheme.primaryAccent),
                          const SizedBox(width: 12),
                          Text('Edit Plot', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryAccent)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Text('Delete Plot', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Zone 2: Dedicated Weather Container
          if (current != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Text(
                    '${WeatherLocationService.getWeatherEmoji(current['weather_code'] ?? 0)} ${current['temperature_2m']}°C',
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.droplets, size: 12, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text('${current['precipitation']}mm', style: GoogleFonts.inter(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.wind, size: 12, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text('${current['wind_speed_10m']}km/h', style: GoogleFonts.inter(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.primaryAccent.withOpacity(0.05),
            ),
          ),
          
          // Zone 3: Core Metrics (Non-scrollable)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricChip(context, LucideIcons.mapPin, 'LOCATION', plot.location),
              _metricChip(context, LucideIcons.calendar, 'PLANTED', plot.plantingDate),
              _metricChip(context, LucideIcons.ruler, 'FIELD SIZE', '${plot.fieldSize} Ha'),
            ],
          ),
          
          // Footer: Status and Weather Timestamp
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(context),
              if (fetchedAt != null)
                Row(
                  children: [
                    Icon(LucideIcons.cloudRain, size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Weather updated: ${DateFormat('h:mm a').format(DateTime.parse(fetchedAt))}',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent.withOpacity(0.04), // Very subtle background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryAccent.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF81C784).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            plot.status,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
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
