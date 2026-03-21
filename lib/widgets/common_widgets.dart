mport 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../models/plot.dart';

class FarmingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  onst FarmingCard({
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
