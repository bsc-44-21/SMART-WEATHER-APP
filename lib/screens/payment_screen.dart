import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/paychangu_service.dart';
import '../services/firestore_service.dart';
import 'paychangu_webview_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _lastTxRef;

  Future<void> _upgradeToPremium() async {
    final user = context.read<AuthService>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('Starting payment for user: ${user.email}');
      
      // Create payment session via Paychangu API to get checkout URL
      final paymentResponse = await PaychanguService.createPaymentSession(
        email: user.email ?? 'user@weathersmart.com',
        firstName: user.displayName?.split(' ').first ?? 'Smart',
        lastName: user.displayName?.split(' ').last ?? 'Farmer',
        amount: 2500.0,
      );

      debugPrint('Payment response received: $paymentResponse');

      _lastTxRef = paymentResponse.txRef;
      final checkoutUrl = paymentResponse.checkoutUrl;

      debugPrint('Checkout URL: $checkoutUrl');

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment gateway unavailable. Please try again later.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        final bool? success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaychanguWebViewScreen(checkoutUrl: checkoutUrl),
          ),
        );

        if (mounted) {
          if (success == true) {
            // Auto-verify if we detected a success return URL
            await _verifyPayment();
          } else {
            setState(() {
              _isVerifying = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please click Verify if you have completed the payment.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Error: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyPayment() async {
    if (_lastTxRef == null) return;
    
    final user = context.read<AuthService>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final isSuccess = await PaychanguService.verifyTransaction(_lastTxRef!, expectedAmount: 2500.0);
      
      if (isSuccess) {
        await _handleSuccessfulPayment(user.uid);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment not yet verified. Please ensure you have completed the transaction.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulPayment(String userId) async {
    await Provider.of<FirestoreService>(context, listen: false).updateUserSubscription(userId, true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully upgraded to Premium!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Upgrade to Premium', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryAccent, AppTheme.primaryHover],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryAccent.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.crown, color: Colors.amber, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Smart Weather Premium',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MWK 2,500 / month',
                      style: GoogleFonts.inter(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Premium Features', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFeatureItem('7-day weather forecast'),
              _buildFeatureItem('Unlimited plots tracking'),
              _buildFeatureItem('Unlimited AI Agricultural advice'),
              _buildFeatureItem('Unlimited Pest & Disease scans'),
              _buildFeatureItem('Professional, unbranded PDF reports'),
              const SizedBox(height: 48),
              if (!_isVerifying)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _upgradeToPremium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Pay with Paychangu (Airtel/Mpamba)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('I have paid (Verify Transaction)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isVerifying = false),
                      child: Text('Cancel / Try again', style: GoogleFonts.inter(color: Colors.redAccent)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, color: AppTheme.primaryAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 16))),
        ],
      ),
    );
  }
}