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
