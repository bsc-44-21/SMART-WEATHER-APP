import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pest_detection.dart';
import 'package:intl/intl.dart';

class ReportService{
     static Future<void> generateAndShareReport(PestDetectionModel detection) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(detection.timestamp);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'WeatherSmart AI',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text('Agricultural Diagnosis Report'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Date: $dateStr'),
                        pw.Text('Report ID: ${detection.id.substring(0, 8)}'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.grey300, height: 40),

                 // Diagnosis Summary
                pw.Text(
                  'Diagnosis: ${detection.pestName}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: detection.riskLevel.toLowerCase() == 'high' 
                        ? PdfColors.red800 
                        : PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Plot Name: ${detection.plotName}'),
                pw.Text('Crop Type: ${detection.cropType}'),
                pw.Text('Risk Level: ${detection.riskLevel}'),
                pw.SizedBox(height: 24),

                // Symptoms
                pw.Text(
                  'Signs & Symptoms',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Bullet(text: detection.symptoms.join('\n')),
                pw.SizedBox(height: 24),

                // Impact
                pw.Text(
                  'Impact on Crop',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(detection.impact),
                pw.SizedBox(height: 24),

                // Smart Weather Advice
                if (detection.weatherAdvice != null && detection.weatherAdvice!.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Smart Weather Advisory',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(detection.weatherAdvice!),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),
                ],
                // Treatment Recommendations
                pw.Text(
                  'Treatment Plan',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),
                
                pw.Text('Organic Recommendations (Malawi):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...detection.naturalRecommendations.map((e) => pw.Text('- $e')),
                
                pw.SizedBox(height: 12),
                pw.Text('Chemical Recommendations (Agro-dealers):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...detection.chemicalRecommendations.map((e) => pw.Text('- $e')),

                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Generated by Smart Weather App - Empowering Malawian Farmers',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    // Save and Share
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'WeatherSmart_Report_${detection.pestName.replaceAll(' ', '_')}.pdf',
    );
  }
}