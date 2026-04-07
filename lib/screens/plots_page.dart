import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';

import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plot_detail_page.dart';

class PlotsPage extends StatefulWidget {
  const PlotsPage({super.key});

  @override
  State<PlotsPage> createState() => _PlotsPageState();
}

class _PlotsPageState extends State<PlotsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch weather when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherSmartService>().fetchWeatherForLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final bool hasPlots = plots.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plots'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Plots list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<WeatherSmartService>().fetchWeatherForPlots();
                  if (context.mounted) {
                  await context.read<WeatherSmartService>().fetchWeatherForLocation();
                  }
                },
                child: hasPlots
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                        itemCount: plots.length,
                        itemBuilder: (context, index) {
                          final plot = plots[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: FarmingCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlotDetailPage(initialPlot: plot),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(plot.cropEmoji, style: const TextStyle(fontSize: 24)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plot.name,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${plot.cropName} • ${plot.fieldSize} Ha',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plot.status,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF2E7D32),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : SingleChildScrollView( // Allow pull-to-refresh even when empty
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.map,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No plots yet',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first plot to get started',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreatePlotBottomSheet(context),
        backgroundColor: AppTheme.primaryAccent,
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: const Text(
          "Add Plot",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
