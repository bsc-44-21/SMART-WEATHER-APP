import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help Center', style: Theme.of(context).textTheme.titleLarge),
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
               'How can we help you?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            _buildFaqItem(
              context,
              'How does the AI Advisory work?', 
              'The AI Advisory analyzes your specific crop (Maize, Tomato, or Groundnuts) alongside hourly and daily weather forecasts to provide tailored farming advice. Free plan users get 3 AI queries per day.'
            ),
             _buildFaqItem(
              context,
              'How do I use Pest Detection?', 
              'Navigate to the Detect tab and capture an image of the affected plant. Our AI will identify the pest and provide natural and chemical control recommendations suitable for Malawi, while factoring in the current weather.'
            ),
_buildFaqItem(
              context,
              'How do I log a farm activity?', 
              'Go to the Activity Log tab and tap "Log Activity". Select your plot, date, and describe the activity (e.g., "Apply fertilizer"). The AI will advise if the timing and weather are suitable.'
 _buildFaqItem(
              context,
              'How do I upgrade to Premium?', 
              'Go to your Profile Preferences and tap the "Upgrade" button. Payments are processed securely via Paychangu. Premium gives you unlimited AI queries.'
            ),
const SizedBox(height: 32),
            Center(

 child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'smartweatherapp@gmail.com',
                    query: 'subject=Smart Weather App Support Request',
);
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    if (context.mounted) {
                      // Fallback: Copy to clipboard
                      await Clipboard.setData(const ClipboardData(text: 'smartweatherapp@gmail.com'));
if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email copied to clipboard: smartweatherapp@gmail.com'),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      // Show dialog with the email clearly
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Contact Support'),
                            content: const SelectableText(
                              'smartweatherapp@gmail.com',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),  
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
 ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.email),
                label: const Text('Contact Support'),
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
       margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
iconColor: AppTheme.primaryAccent,
        collapsedIconColor: AppTheme.primaryAccent,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [

