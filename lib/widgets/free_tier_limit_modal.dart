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

class _FreeTierLimitModal extends StatelessWidget {
  final String featureName;
  final String limitText;

  const _FreeTierLimitModal({
    required this.featureName,
    required this.limitText,
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.terracotta.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.crown,
                color: AppTheme.terracotta,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Free Tier Reached',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.terracotta,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have reached the free limit for $featureName ($limitText). Upgrade to Premium to enjoy unlimited access and unlock all professional farming tools.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Upgrade to Premium',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe Later',
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
}
