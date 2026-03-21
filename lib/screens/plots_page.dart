import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../services/weather_smart_service.dart';
import '../widgets/create_plot_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class PlotsPage extends StatelessWidget {
  const PlotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Farming Plots', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showCreatePlotBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (plots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Text('No plots added yet. Click + to add one.'),
              ),
            )
          else
            ...plots.map((plot) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PlotInfoCard(
                    plot: plot,
                    onEdit: () => showCreatePlotBottomSheet(context, existingPlot: plot),
                    onDelete: () => showDeleteConfirmationDialog(context, plot: plot),
                  ),
                )),
        ],
      ),
    );
  }
}
