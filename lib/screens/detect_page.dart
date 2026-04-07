import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_advisory_service.dart';
import '../models/pest_detection.dart';
import '../models/plot.dart';
import '../services/weather_location_service.dart';
import 'detection_result_page.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  File? _selectedImage;
  
  // Animation for scanning line
  late AnimationController _scanController;
  int _statusIndex = 0;
  final List<String> _statusMessages = [
    'Analyzing leaf patterns...',
    'Identifying pests & diseases...',
    'Cross-referencing Malawian data...',
    'Consulting local weather patterns...',
    'Generating treatment plan...',
  ];
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startAIStatusCycle() {
    setState(() { _statusIndex = 0; });
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_statusIndex < _statusMessages.length - 1) {
        if (mounted) setState(() { _statusIndex++; });
      }
    });
    _scanController.repeat(reverse: true);
  }

  void _stopAIStatusCycle() {
    _statusTimer?.cancel();
    _scanController.stop();
  }

  Future<void> _scanPest() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final weatherService = Provider.of<WeatherSmartService>(context, listen: false);
    final userId = authService.user?.uid;

    if (userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to use this feature.')),
      );
      return;
    }

    // 1. Plot Selection (Linked to User's Plots)
    final List<PlotModel> userPlots = weatherService.plots;

    if (userPlots.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Plots Found'),
            content: const Text('You need to create a plot first to detect pests. This helps us know what crop we are analyzing.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigation handled by the app's main bottom nav or a dedicated route
                },
                child: const Text('Go to Plots'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final PlotModel? selectedPlot = await showDialog<PlotModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Affected Plot'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userPlots.length,
            itemBuilder: (context, index) {
              final plot = userPlots[index];
              return ListTile(
                leading: Text(
                  plot.cropName.toLowerCase().contains('maize') ? '🌽' : 
                  plot.cropName.toLowerCase().contains('tomato') ? '🍅' : '🥜',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(plot.name),
                subtitle: Text('Crop: ${plot.cropName}'),
                onTap: () => Navigator.pop(context, plot),
              );
            },
          ),
        ),
      ),
    );

    if (selectedPlot == null) return;
    final selectedCrop = selectedPlot.cropName;
    final plotName = selectedPlot.name;

    // 2. Image Selection
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isProcessing = true;
        });
        _startAIStatusCycle();
        
        // 3. AI Detection & Advisory (Gemini Vision)
        // Get current weather context for "Smart Advisory"
        final weatherSummary = weatherService.currentWeather != null 
          ? "Condition: ${WeatherLocationService.getWeatherDescription(weatherService.currentWeather!['daily']['weather_code'][0])}"
          : null;

        final Map<String, dynamic> advice = await AiAdvisoryService.getPestReportFromImage(
          imageFile: File(image.path),
          cropName: selectedCrop,
          weatherSummary: weatherSummary,
        );

        if (advice['is_valid'] == false) {
          setState(() {
            _isProcessing = false;
            _selectedImage = null;
          });
          _stopAIStatusCycle();
          if (mounted) {
            _showInvalidImageDialog(advice['rejection_reason'] ?? 'This image does not appear to be a related crop.');
          }
          return;
        }
        
        // 4. Save to Firestore
        final detection = PestDetectionModel(
          id: const Uuid().v4(),
          userId: userId,
          cropType: selectedCrop,
          plotName: plotName, // Added
          pestName: advice['pest_name'] ?? 'Unknown Pest',
          symptoms: List<String>.from(advice['signs_symptoms'] ?? []),
          impact: advice['bad_impact'] ?? '',
          naturalRecommendations: List<String>.from(advice['natural_recommendations'] ?? []),
          chemicalRecommendations: List<String>.from(advice['chemical_recommendations'] ?? []),
          riskLevel: advice['risk_level'] ?? 'Low',
          timestamp: DateTime.now(),
          weatherAdvice: advice['smart_weather_advice'],
        );

        await firestoreService.savePestDetection(detection);

        setState(() {
          _isProcessing = false;
        });
        _stopAIStatusCycle();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetectionResultPage(detection: detection),
            ),
          ).then((_) {
            if (mounted) {
              setState(() {
                _selectedImage = null;
              });
            }
          });
        }
      }
    } catch (e) {
      _stopAIStatusCycle();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showInvalidImageDialog(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppTheme.primaryAccent),
            const SizedBox(width: 10),
             Text(
              'Invalid Image',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          reason,
          style: GoogleFonts.inter(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _scanPest(); // Trigger scan again
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            _buildHistoryStream(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (_selectedImage != null)
              Positioned.fill(
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            if (_selectedImage != null)
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Opacity(
                opacity: _isProcessing ? 0.0 : 1.0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.scanLine,
                        size: 56,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Scan Crop or Pest',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your crops healthy and safe',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _scanPest,
                      icon: const Icon(LucideIcons.camera, color: Colors.white),
                      label: const Text('Tap to Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppTheme.primaryAccent,
                        disabledBackgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), 
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isProcessing)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            Positioned(
                              top: _scanController.value * constraints.maxHeight,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryAccent.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: AppTheme.primaryAccent,
                                ),
                              ),
                            ),
                            Container(
                              color: AppTheme.primaryAccent.withValues(alpha: 0.05),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStream(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final userId = authService.user?.uid;

    if (userId == null) return const Text('Please login to see history.');

    return StreamBuilder<List<PestDetectionModel>>(
      stream: firestoreService.getUserPestDetectionsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No scans yet.', style: TextStyle(color: Colors.black54)),
          );
        }

        final history = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildHistoryItem(
              context: context,
              detection: history[index],
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required PestDetectionModel detection,
  }) {
    final isCritical = detection.riskLevel.toLowerCase() == 'high';
    
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetectionResultPage(detection: detection),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCritical
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? LucideIcons.bug : LucideIcons.checkCircle,
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
                    detection.pestName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${detection.plotName} • ${detection.cropType} • ${timeAgoLabel(detection.timestamp)}",
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
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                detection.riskLevel,
                style: TextStyle(
                  color: isCritical ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDeleteDetection(context, detection),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
          ),
        ),
      ),
    );
  }

  String timeAgoLabel(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) return "${difference.inDays}d ago";
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m ago";
    return "Just now";
  }

  void _confirmDeleteDetection(BuildContext context, PestDetectionModel detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to delete the pest report for ${detection.pestName}? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                await firestoreService.deletePestDetection(detection.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report deleted successfully.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}