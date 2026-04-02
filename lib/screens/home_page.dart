import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';
import '../widgets/create_plot_sheet.dart';
import 'notifications_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final plots = weatherService.plots;
    final logs = weatherService.logs;
    final advice = weatherService.advice;
    final currentWeather = weatherService.currentWeather;

    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? user?.email?.split('@')[0] ?? 'Farmer';

    // Calculate total area
    double totalArea = 0;
    for (var plot in plots) {
      totalArea += double.tryParse(plot.fieldSize) ?? 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    username,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  final unreadCount = notificationService.unreadCount;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.bell),
                          color: AppTheme.primaryAccent,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 2. Global Local Weather
          if (currentWeather != null) ...[
            _buildLocalWeatherCard(context, currentWeather),
            const SizedBox(height: 24),
          ],

          // 3. Farm Analytics
          Row(
            children: [
              Expanded(
                child: _buildAnalyticCard(
                  context,
                  title: 'Total Plots',
                  value: '${plots.length}',
                  icon: LucideIcons.map,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticCard(
                  context,
                  title: 'Total Area',
                  value: '${totalArea.toStringAsFixed(1)} Ha',
                  icon: LucideIcons.maximize,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 4. Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            icon: LucideIcons.plus,
            title: 'Add New Plot',
            subtitle: 'Register a new field',
            onTap: () => showCreatePlotBottomSheet(context),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            context,
            icon: LucideIcons.clipboardList,
            title: 'Log Activity',
            subtitle: 'Record farm tasks & events',
            onTap: () => context.read<NavigationService>().setIndex(3),
          ),

          const SizedBox(height: 32),

          // 5. Smart Insights (Tip of the Day)
          Text(
            'Tip of the Day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          FarmingCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.lightbulb, color: Colors.orangeAccent, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    advice,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Recent Logs
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...logs.take(2).map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FarmingCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.clipboardList, size: 16, color: AppTheme.primaryAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        log['title'] ?? 'Activity',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      log['time'] ?? '',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLocalWeatherCard(BuildContext context, Map<String, dynamic> weather) {
    final current = weather['current'];
    if (current == null) return const SizedBox.shrink();

    final temp = current['temperature_2m'];
    final weatherCode = current['weather_code'];
    final emoji = WeatherLocationService.getWeatherEmoji(weatherCode);
    final desc = WeatherLocationService.getWeatherDescription(weatherCode);

    return FarmingCard(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent, // Dark mode card
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Local Weather',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$temp°',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      desc,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryAccent.withOpacity(0.5), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
