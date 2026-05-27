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

