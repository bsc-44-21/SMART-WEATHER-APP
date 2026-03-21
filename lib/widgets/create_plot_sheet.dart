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
