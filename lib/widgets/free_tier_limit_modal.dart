import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../screens/payment_screen.dart';

void showFreeTierLimitModal(BuildContext context, {required String featureName, required String limitText}) {
  showDialog(
    context: context,
    builder: (context) => _FreeTierLimitModal(
      featureName: featureName,
      limitText: limitText,
    ),
  );
}