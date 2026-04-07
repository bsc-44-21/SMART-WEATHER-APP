import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../services/weather_smart_service.dart';
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
            color: Colors.black.withValues(alpha: 0.05),
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

  String _getCropEmoji(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('maize')) return '🌽';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('nut') || lower.contains('g/nut')) return '🥜';
    if (lower.contains('coffee')) return '☕';
    if (lower.contains('cotton')) return '🌿';
    if (lower.contains('tobacco')) return '🚬';
    if (lower.contains('soy')) return '🌿';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = context.watch<WeatherSmartService>().getPlotWeather(plot.id);
    final fetchedAt = weatherData?['fetched_at'];
    final current = weatherData?['current'] as Map<String, dynamic>?;

    return FarmingCard(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header
          Row(
            children: [
              Text(
                _getCropEmoji(plot.cropName),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plot.name,
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${plot.fieldSize} Ha',
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              // Options Menu
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, color: Colors.black87, size: 20),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          Text('Edit Plot', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: AppTheme.primaryAccent)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Text('Delete Plot', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Row 2: Weather Details
          if (current != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.cloud, size: 14, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${current['temperature_2m']}°',
                    style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.droplets, size: 14, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${current['precipitation']}mm',
                    style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.wind, size: 14, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${current['wind_speed_10m']}km/h',
                    style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          if (current == null) const SizedBox(height: 12),

          // Row 3: Plot Details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text(
                      plot.location,
                      style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text(
                      plot.plantingDate,
                      style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          
          // Row 4: Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(),
              if (fetchedAt != null)
                Text(
                  'updated: ${DateFormat('hh:mm a').format(DateTime.parse(fetchedAt))}',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            plot.status,
            style: GoogleFonts.inter(
              color: const Color(0xFF2E7D32),
              fontSize: 10,
              fontWeight: FontWeight.w600,
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
