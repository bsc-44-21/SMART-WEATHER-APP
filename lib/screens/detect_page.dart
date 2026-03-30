import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _history = [
    {
      'title': 'Fall Armyworm',
      'date': 'Today, 10:30 AM',
      'status': 'Detected - High Risk',
      'isCritical': true,
      'icon': LucideIcons.bug,
    },
    {
      'title': 'Healthy Maize Leaf',
      'date': 'Yesterday, 2:15 PM',
      'status': 'Clear',
      'isCritical': false,
      'icon': LucideIcons.checkCircle,
    },
    {
      'title': 'Aphids Detected',
      'date': 'Mon, 9:00 AM',
      'status': 'Low Risk',
      'isCritical': false,
      'icon': LucideIcons.alertTriangle,
    },
  ];

  Future<void> _scanPest() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        // Simulating AI processing time
        setState(() {
          _isProcessing = true;
        });
        
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _isProcessing = false;
          _history.insert(0, {
            'title': 'Unknown Leaf Spot',
            'date': 'Just now',
            'status': 'Detected - Medium Risk',
            'isCritical': true,
            'icon': LucideIcons.scan,
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scan complete! Results added to history.'),
              backgroundColor: AppTheme.primaryAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Pest Detection',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identify pests instantly by scanning your crops.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildScanCard(context),
            const SizedBox(height: 32),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppTheme.primaryAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      // Changed gradient to Deep Olive theme
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent,
            AppTheme.primaryAccent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: _isProcessing 
              ? const SizedBox(
                  width: 56, 
                  height: 56, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)
                )
              : const Icon(
                  LucideIcons.scanLine,
                  size: 56,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            _isProcessing ? 'Analyzing...' : 'Scan Crop or Pest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isProcessing ? 'Please wait while we process the image.' : 'Keep your crops healthy and safe',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _scanPest,
            icon: const Icon(LucideIcons.camera),
            label: const Text('Tap to Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryAccent,
              disabledBackgroundColor: AppTheme.primaryAccent.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (_history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No scans yet.', style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryItem(
          context: context,
          title: item['title'],
          date: item['date'],
          status: item['status'],
          isCritical: item['isCritical'],
          icon: item['icon'],
        );
      },
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required String title,
    required String date,
    required String status,
    required bool isCritical,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCritical
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCritical ? Colors.red : Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCritical
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isCritical ? Colors.red : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
