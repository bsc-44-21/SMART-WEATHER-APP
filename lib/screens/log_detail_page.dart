import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class LogDetailPage extends StatelessWidget {
  final Map<String, dynamic> log;
  final String cropEmoji;

  const LogDetailPage({
    super.key,
    required this.log,
    required this.cropEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final bool? isRec = log['isRecommended'];
    final String title = log['title'] ?? 'Activity Log';
    final String plot = log['plot'] ?? 'General';
    final String time = log['time'] ?? '';
    final String? aiFeedback = log['aiFeedback'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Log Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Text(cropEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Time & Date Card
            _buildDetailSection(
              icon: LucideIcons.calendar,
              title: "Time & Date",
              content: time,
              iconColor: AppTheme.primaryAccent,
            ),
            const SizedBox(height: 16),

            // AI Feedback Section
            if (isRec != null || (aiFeedback != null && aiFeedback.isNotEmpty)) ...[
              Text(
                'AI Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              
              if (isRec != null) ...[
                _AdvisoryStatusCard(isRecommended: isRec),
                const SizedBox(height: 16),
              ],
              
              if (aiFeedback != null && aiFeedback.isNotEmpty)
                _buildDetailSection(
                  icon: LucideIcons.sparkles,
                  title: "Feedback Message",
                  content: aiFeedback,
                  iconColor: Colors.indigo.shade600,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryStatusCard extends StatelessWidget {
  final bool isRecommended;
  const _AdvisoryStatusCard({required this.isRecommended});

  @override
  Widget build(BuildContext context) {
    final color = isRecommended ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isRecommended ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecommended ? "Activity Recommended" : "Caution Advised",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRecommended 
                          ? "This activity aligns well with the current weather conditions."
                          : "Be careful! The weather conditions might not be ideal.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
