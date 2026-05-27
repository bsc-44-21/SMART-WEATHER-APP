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

