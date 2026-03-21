import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_smart_service.dart';
import '../services/auth_service.dart';
import '../models/plot.dart';

void showCreatePlotBottomSheet(BuildContext context, {PlotModel? existingPlot}) {
  final nameController = TextEditingController(text: existingPlot?.name);
  final locationController = TextEditingController(text: existingPlot?.location);
  final sizeController = TextEditingController(text: existingPlot?.size);
  final formKey = GlobalKey<FormState>();
final bool isEditing = existingPlot != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool isSaving = false;
      
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEditing ? 'Edit Plot' : 'Create New Plot', style: 
                    Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Plot Name (e.g. North Field)'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a plot name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Location (e.g. Sector 4)'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a location' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: sizeController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(labelText: 'Size (e.g., 1.5 Ha)'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please 
                      enter the size' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving 
                          ? null 
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              
                              setModalState(() => isSaving = true);
                              
                              final user = context.read<AuthService>().user;
                              if (user == null) {
                                setModalState(() => isSaving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error: Not logged in')),
                                );
                                return;
                              }

                              final plotName = nameController.text.trim();
                              final plot = PlotModel(
                                id: isEditing ? existingPlot!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                                name: plotName,
                                location: locationController.text.trim(),
                                size: sizeController.text.trim(),
                                date: isEditing ? existingPlot!.date : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                userId: user.uid,
                                status: isEditing ? existingPlot!.status : 'Active Growth',
                              );
                              
                              try {
                                if (isEditing) {
                                  await context.read<WeatherSmartService>().updatePlot(plot);
                                } else {
                                  await context.read<WeatherSmartService>().addPlot(plot);
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEditing ? 'Plot "$plotName" updated!' : 'Plot "$plotName" successfully created!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setModalState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to create plot: $e'), backgroundColor: Colors.red),
                                                                      );
                                }
                              }
                            },
                        child: isSaving 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEditing ? 'Update Plot' : 'Save Plot'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
