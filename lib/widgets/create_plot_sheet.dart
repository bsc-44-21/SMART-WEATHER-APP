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