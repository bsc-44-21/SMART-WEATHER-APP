import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Terms of Reference', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
 body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(context).textTheme.displayMedium,
            ),
             const SizedBox(height: 16),
            Text(
              'Last updated: May 2026',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
'By accessing and using the Smart Weather App, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              context,
              '2. Description of Service',
              'Smart Weather App provides Malawian farmers with weather forecasting tools, AI-based crop advisory (for Maize, Tomato, and Groundnuts), pest detection via image analysis, and farm activity logging.',
 ),
            _buildSection(
              context,
              '3. AI Advisory Disclaimer',
              'The Gemini AI Advisory and pest detection results are provided for informational purposes only. The app shall not be held liable for any crop yield losses or agricultural damages resulting from the use of the service. Always exercise local agricultural best practices.',
            ),