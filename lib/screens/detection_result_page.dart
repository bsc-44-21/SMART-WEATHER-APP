import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/pest_detection.dart';
import '../services/report_service.dart';

class DetectionResultPage extends StatelessWidget {
  final PestDetectionModel detection;

  const DetectionResultPage({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    final riskLower = detection.riskLevel.toLowerCase();
    final isHighRisk = riskLower == 'high';
    final isMediumRisk = riskLower == 'medium';
    
    final Color riskColor = isHighRisk 
        ? Colors.red 
        : (isMediumRisk ? Colors.orange : Colors.green);
          return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, riskColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(riskColor),
                  const SizedBox(height: 20),
                  _buildThreatMeter(riskColor),
                  const SizedBox(height: 24),
                  
                  if (detection.weatherAdvice != null && detection.weatherAdvice!.isNotEmpty) ...[
                    _buildWeatherAdviceCard(),
                    const SizedBox(height: 24),
                  ],
