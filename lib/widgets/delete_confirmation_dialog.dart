import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plot.dart';
import '../services/weather_smart_service.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context, {required PlotModel plot}) async {
  final controller = TextEditingController();
  bool isSaving = false;
    return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isMatch = controller.text.trim() == plot.name;
                    return AlertDialog(
            title: Text('Delete ${plot.name}?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [