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
            // Title
            Text(
              'Verify Payment',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),

            // Description / Transaction Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Amount', 'MWK ${amount.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Ref', txRef.length > 15 ? '${txRef.substring(0, 12)}...' : txRef),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // The specific message requested by the user
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (errorMessage != null ? Colors.red : Colors.orange).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (errorMessage != null ? Colors.red : Colors.orange).withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                   Icon(
                    errorMessage != null ? LucideIcons.alertTriangle : LucideIcons.info,
                    color: errorMessage != null ? Colors.red : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'payment not verified .please ensure you have completed  the transaction',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: errorMessage != null ? Colors.red.shade900 : Colors.orange.shade900,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Verify Payment',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

void showPaymentVerificationModal(
  BuildContext context, {
  required String txRef,
  required double amount,
  required VoidCallback onVerify,
  required VoidCallback onCancel,
  bool isLoading = false,
  String? errorMessage,
}) {
  showDialog(
    context: context,
    barrierDismissible: !isLoading,
    builder: (context) => PaymentVerificationModal(
      txRef: txRef,
      amount: amount,
      onVerify: onVerify,
      onCancel: onCancel,
      isLoading: isLoading,
      errorMessage: errorMessage,
    ),
  );
}

