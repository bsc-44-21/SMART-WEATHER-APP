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