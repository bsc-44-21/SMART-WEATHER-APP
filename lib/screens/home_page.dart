import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final bool hasPlots = plots.isNotEmpty;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPlots) ...[
            Text('Your Active Plots', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...plots.map((plot) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PlotInfoCard(
                plot: plot,
                onEdit: () => showCreatePlotBottomSheet(context, existingPlot: plot),
                // Secure delete from home as well
                onDelete: () => showDeleteConfirmationDialog(context, plot: plot),
              ),
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showCreatePlotBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.plus, size: 20),
                  SizedBox(width: 8),
                  Text('Add Another Plot'),
                ],
              ),
            ),
            ] else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                FarmingCard(
                  padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
                  child: Column(
                    children: [
                      const AppLogo(size: 84, backgroundColor: Color(0xFFF0F0E8)),
                      const SizedBox(height: 32),
                      Text('Welcome to WeatherSmart', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(
                        'Create your first farming plot to start receiving intelligent weather-based advice and pest detection.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),