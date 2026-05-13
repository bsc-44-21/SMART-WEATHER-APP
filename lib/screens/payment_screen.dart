import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/paychangu_service.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import '../core/secrets.dart';
import 'paychangu_webview_screen.dart';
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
      _lastTxRef = 'tx-${const Uuid().v4().substring(0, 8)}';
      final String publicKey = AppSecrets.paychanguPublicKey;
      
      final htmlContent = '''
      <!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://in.paychangu.com/js/popup.js"></script>
  <style>
    body { 
      display: flex; 
      justify-content: center; 
      align-items: center; 
      height: 100vh; 
      margin: 0; 
      background-color: #ffffff; 
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }
    .loading-container {
      text-align: center;
    }
    .loader {
      border: 4px solid #f3f3f3;
      border-top: 4px solid #E65C4F;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 2s linear infinite;
      margin: 0 auto 20px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
      button { 
      padding: 16px 32px; 
      font-size: 16px; 
      font-weight: bold; 
      background-color: #E65C4F; 
      color: white; 
      border: none; 
      border-radius: 12px; 
      cursor: pointer;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
      </style>
</head>
<body>
  <div class="loading-container" id="loading-ui">
    <div class="loader"></div>
    <p>Preparing secure payment...</p>
    <button type="button" id="pay-button" style="display:none;" onClick="makePayment()">Pay Now</button>
  </div>
  
  <div id="wrapper"></div>

  <script>
    function makePayment(){
      try {
        PaychanguCheckout({
          "public_key": "$publicKey",
          "tx_ref": "$_lastTxRef",
          "amount": 2500,
          "currency": "MWK",
          "callback_url": "https://smartweather.app/success",
          "return_url": "https://smartweather.app/success",
          "customer":{
            "email": "${user.email ?? 'user@weathersmart.com'}",
            "first_name": "${user.displayName?.split(' ').first ?? 'Smart'}",
            "last_name": "${user.displayName?.split(' ').last ?? 'Farmer'}"
          },
          "customization": {
            "title": "Smart Weather Premium",
            "description": "Payment for Premium Subscription"
          },
          "meta": {
            "uuid": "${const Uuid().v4()}",
            "source": "flutter_app"
          }
             });
      } catch (e) {
        console.error("Paychangu Error:", e);
        document.getElementById('loading-ui').innerHTML = '<p style="color:red">Error initializing payment. Please try again.</p>';
      }
    }

    // Automatically trigger payment when page loads
    window.onload = function() {
      // Give a small delay to ensure script is ready
      setTimeout(function() {
        makePayment();
        // Show button only if it doesn't auto-open after 3 seconds
        setTimeout(function() {
          document.getElementById('pay-button').style.display = 'block';
        }, 3000);
      }, 500);
    };
  </script>
</body>
</html>
''';

      if (mounted) {
        final bool? success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaychanguWebViewScreen(htmlContent: htmlContent),
          ),
        );

        if (mounted) {
          if (success == true) {
            // Auto-verify if we detected a success return URL
            await _verifyPayment();
          } else {
            setState(() {
              _isVerifying = true;
              _isLoading = false;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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