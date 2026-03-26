import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 32),

              // Notifications List
              Expanded(
                child: ListView(
                  children: const [
                    _NotificationCard(
                      icon: LucideIcons.alertTriangle,
                      title: 'Urgent Warning',
                      message: 'Heavy rains may damage your crops. Take action immediately.',
                      time: '2 min ago',
                      color: Color(0xFFFFEBEE), // Very light red
                      iconColor: Colors.red,
                    ),
                    SizedBox(height: 16),
                    _NotificationCard(
                      icon: LucideIcons.cloudRain,
                      title: 'Rain Alert',
                      message: 'Heavy rains may damage your crops. Take action immediately.',
                      time: '12 min ago',
                      color: Color(0xFFE8EAF6), // Very light indigo
                      iconColor: Colors.indigo,
                    ),
                    SizedBox(height: 16),
                    _NotificationCard(
                      icon: LucideIcons.bug,
                      title: 'Pest Risk Predicted',
                      message: 'Heavy rains may damage your crops. Take action immediately.',
                      time: '40 min ago',
                      color: Color(0xFFE8F5E9), // Very light green
                      iconColor: Colors.green,
                    ),
                    SizedBox(height: 16),
                    _NotificationCard(
                      icon: LucideIcons.leaf,
                      title: 'Fertilizer Tip',
                      message: 'Apply nitrogen fertilizer this week for better growth.',
                      time: '1 Day ago',
                      color: Colors.white,
                      iconColor: Colors.black54,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Back Button
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
                  child: Text(
                    'Back to Settings',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    required this.iconColor,
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
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: iconColor == Colors.black54 ? AppTheme.textPrimary : iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
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
                    style: TextStyle(
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
