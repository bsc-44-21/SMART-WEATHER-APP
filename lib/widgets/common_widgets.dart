import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../models/plot.dart';

class FarmingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const FarmingCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(44),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(32.0),
          child: child,
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
    return FarmingCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(size: 48, backgroundColor: Color(0xFFF0F0E8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(plot.name, style: Theme.of(context).textTheme.titleLarge)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.edit, size: 18),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'Edit Plot',
                        ),

                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 18),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.red.shade400,
                          tooltip: 'Delete Plot',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(plot.location, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.calendar, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(plot.date, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.ruler, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(plot.size, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plot.status,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
