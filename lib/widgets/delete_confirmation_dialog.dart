import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plot.dart';
import '../services/weather_smart_service.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context, {required PlotModel plot}) async {
  final controller = TextEditingController();
  bool isSaving = false;