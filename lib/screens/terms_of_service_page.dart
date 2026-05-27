import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Privacy Support', style: Theme.of(context).textTheme.titleLarge),
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
              'Privacy Policy',
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
              '1. Information We Collect',
              'We collect information you provide directly to us when creating an account, including your email and display name.',
            ),
             _buildSection(
              context,
              '2. Farm and Location Data',
              'To provide hyper-local weather forecasts and accurate AI advice, we collect data about your farm plots. This includes the plot latitude and longitude coordinates, crop types (Maize, Tomato, or Groundnuts), and planting dates.',
            ),
             _buildSection(
              context,
              '3. Images and AI Analysis',
              'When you use the Pest Detection feature, the images you capture are temporarily sent to the Google Gemini AI for analysis. We do not permanently store these images or use them for training other models.',
            ),
            _buildSection(
              context,
              '4. Payment Processing',
              'Premium subscriptions are processed securely through Paychangu. We do not directly collect or store your full credit card details or mobile money PINs on our servers.',
            ),
             _buildSection(
              context,
              '5. Data Security',
              'We secure your data using Firebase Authentication and Firestore rules to prevent unauthorized access to your farm logs and plot data.',
            ),
            const SizedBox(height: 16),
            Text(
              'If you have any questions about this Privacy Policy or your data, please contact our support team.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
   Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title






