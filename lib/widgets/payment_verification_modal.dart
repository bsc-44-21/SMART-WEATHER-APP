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

  const PaymentVerificationModal({
    super.key,
    required this.txRef,
    required this.amount,
    required this.onVerify,
    required this.onCancel,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (errorMessage != null ? Colors.orange : AppTheme.primaryAccent).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorMessage != null ? LucideIcons.alertCircle : LucideIcons.refreshCw,
                color: errorMessage != null ? Colors.orange : AppTheme.primaryAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),