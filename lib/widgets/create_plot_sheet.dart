import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../services/auth_service.dart';
import '../models/plot.dart';
import '../services/notification_service.dart';

void showCreatePlotBottomSheet(BuildContext context, {PlotModel? existingPlot}) {
  final nameController = TextEditingController(text: existingPlot?.name);
  final locationController = TextEditingController(text: existingPlot?.location);
  final sizeController = TextEditingController(text: existingPlot?.fieldSize);
  final dateController = TextEditingController(text: existingPlot?.plantingDate);
  final latController = TextEditingController(text: existingPlot?.latitude);
  final lngController = TextEditingController(text: existingPlot?.longitude);
  final formKey = GlobalKey<FormState>();
final bool isEditing = existingPlot != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool isSaving = false;
      String? selectedCrop = existingPlot?.cropName;
      String? selectedCropId = existingPlot?.cropId;
      bool isFetchingLocation = false;

      final List<Map<String, String>> crops = [
        {'id': '1', 'name': 'Maize'},
        {'id': '2', 'name': 'Tomato'},
        {'id': '3', 'name': 'G/Nuts'},
      ];

      return StatefulBuilder(
        builder: (context, setModalState) {
          String? capturedCoords;
          if (latController.text.isNotEmpty && lngController.text.isNotEmpty) {
            capturedCoords = 'Coordinates: ${latController.text}, ${lngController.text}';
          }

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
                child: SingleChildScrollView(
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
                      decoration: const InputDecoration(labelText: 'Plot Name'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a plot name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      enabled: !isSaving && !isFetchingLocation,
                      decoration: InputDecoration(
                        labelText: 'Location Name',
                        helperText: capturedCoords,
                        helperStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        suffixIcon: isFetchingLocation 
                          ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: () async {
                                setModalState(() => isFetchingLocation = true);
                                final pos = await WeatherLocationService.getLocationWithPermission();
                                if (pos != null) {
                                  setModalState(() {
                                    latController.text = pos.latitude.toStringAsFixed(4);
                                    lngController.text = pos.longitude.toStringAsFixed(4);
                                    isFetchingLocation = false;
                                  });
                                } else {
                                  setModalState(() => isFetchingLocation = false);
                                  if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to get location. Ensure location services are enabled.')),
                                  );
                                  }
                                }
                              },
                            ),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a location name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: sizeController,
                      enabled: !isSaving,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Field Size',
                        hintText: 'e.g. 2.5',
                        suffixText: 'ha',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter the size' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      enabled: !isSaving,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Planting Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: isSaving ? null : () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please select a planting date' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCrop,
                      decoration: const InputDecoration(labelText: 'Crop Type'),
                      items: crops.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop['name'],
                          child: Text(crop['name']!),
                        );
                      }).toList(),
                      onChanged: isSaving ? null : (value) {
                        setModalState(() {
                          selectedCrop = value;
                          selectedCropId = crops.firstWhere((c) => c['name'] == value)['id'];
                        });
                      },
                      validator: (value) => value == null ? 'Please select a crop type' : null,
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

                                // Capture location if fields are empty
                                if (latController.text.isEmpty || lngController.text.isEmpty) {
                                  setModalState(() => isSaving = true);
                                   final pos = await WeatherLocationService.getLocationWithPermission();
                                   if (pos != null) {
                                     latController.text = pos.latitude.toString();
                                     lngController.text = pos.longitude.toString();
                                   } else {
                                     setModalState(() => isSaving = false);
                                     if (context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('Could not capture location automatically. Please enter coordinates manually or tap the icon.')),
                                       );
                                     }
                                     return;
                                   }
                                }

                              final now = DateTime.now().toIso8601String();
                              final plotName = nameController.text.trim();
                              final plot = PlotModel(
                                id: isEditing ? existingPlot.id : DateTime.now().millisecondsSinceEpoch.toString(),
                                name: plotName,
                                location: locationController.text.trim(),
                                latitude: latController.text.trim(),
                                longitude: lngController.text.trim(),
                                fieldSize: sizeController.text.trim(),
                                plantingDate: dateController.text.trim(),
                                userId: user.uid,
                                cropId: selectedCropId ?? '',
                                cropName: selectedCrop ?? '',
                                createdAt: isEditing ? existingPlot.createdAt : now,
                                modifiedAt: now,
                                status: isEditing ? existingPlot.status : 'Active Growth',
                              );
                              
                              try {
                                if (isEditing) {
                                  await context.read<WeatherSmartService>().updatePlot(plot);
                                } else {
                                  await context.read<WeatherSmartService>().addPlot(plot);
                                }

                                if (context.mounted) {
                                  final weatherService = context.read<WeatherSmartService>();
                                  final logs = weatherService.logs;
                                  final plotWeather = weatherService.getPlotWeather(plot.id);
                                  context.read<NotificationService>().schedulePlotMilestones(plot, logs, plotWeather: plotWeather);
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
            ),
          );
        },
      );
    },
  );
}
