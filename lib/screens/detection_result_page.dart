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
                   _buildSectionTitle('signs & symptoms'),
                  const SizedBox(height: 12),
                  _buildBulletList(detection.symptoms),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('impact on crop'),
                  const SizedBox(height: 12),
                  Text(
                    detection.impact,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildRecommendationsCard(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ReportService.generateAndShareReport(detection),
        backgroundColor: AppTheme.primaryAccent,
        icon: const Icon(LucideIcons.fileText, color: Colors.white),
        label: const Text('Export PDF Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color riskColor) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: riskColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    riskColor.withOpacity(0.3),
                    riskColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                riskColor == Colors.red ? LucideIcons.bug : LucideIcons.checkCircle,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
        title: Text(
          detection.pestName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader(Color riskColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: riskColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                riskColor == Colors.red ? LucideIcons.alertCircle : LucideIcons.shieldCheck,
                size: 16,
                color: riskColor,
              ),
              const SizedBox(width: 8),
              Text(
                "${detection.riskLevel} Risk",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: riskColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Plot: ${detection.plotName} | Crop: ${detection.cropType}",
          style: GoogleFonts.inter(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  Widget _buildThreatMeter(Color riskColor) {
    double progress = 0.3;
    if (detection.riskLevel.toLowerCase() == 'medium') progress = 0.6;
    if (detection.riskLevel.toLowerCase() == 'high') progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Threat Level",
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(riskColor),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.cloudRain, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Text(
                'Smart Weather Advice',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detection.weatherAdvice!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.blue.shade900,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        letterSpacing: 1.2,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppTheme.primaryAccent,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Icon(Icons.circle, size: 6, color: Colors.black26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 15, height: 1.4),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                const Icon(LucideIcons.leaf, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  'Treatment Advice',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTabSection('Natural (Malawi)', detection.naturalRecommendations, Colors.green),
            const Divider(height: 40),
            _buildTabSection('Chemical (Available in MW)', detection.chemicalRecommendations, Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: color.withOpacity(0.5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

