import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class PaymentVerificationModal extends StatelessWidget {
  final String txRef;
  final double amount;
  final VoidCallback onVerify;
  final VoidCallback onCancel;
  final bool isLoading;
  final String? errorMessage;