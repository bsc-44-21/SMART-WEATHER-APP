import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/ai_advisory_service.dart';
import '../models/plot.dart';
import 'log_detail_page.dart';

// Public access to the fully featured log bottom sheet
void showFullActivityLogSheet(BuildContext context, {String initialFilter = 'All'}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddActivitySheet(initialFilter: initialFilter),
  );
}

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String _selectedFilter = 'All';

  String _getCropEmoji(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('maize')) return '🌽';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('nut') || lower.contains('g/nut')) return '🥜';
    return '🌱';
  }

  void _showAddActivitySheet(BuildContext context, String currentFilter) {
    showFullActivityLogSheet(context, initialFilter: currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final userPlots = weatherService.plots;
    
    // Filtering logic
    final filteredLogs = weatherService.logs.where((log) {
      if (_selectedFilter == 'All') return true;
      return log['plot'] == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Activity Log',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            if (userPlots.isNotEmpty)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('All'),
                    ...userPlots.map((plot) => _filterChip(plot.name)),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await weatherService.fetchWeatherForPlots();
                },
                child: filteredLogs.isEmpty
                    ? _EmptyLogsState(hasFilter: _selectedFilter != 'All')
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          final plotName = log['plot'] ?? 'General';
                          
                          // Look up the actual crop name from the plot models
                          final plot = userPlots.where((p) => p.name == plotName).toList();
                          final cropName = plot.isNotEmpty ? plot.first.cropName : 'General';
                          
                          return _ActivityLogTile(
                            log: log,
                            cropEmoji: _getCropEmoji(cropName),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivitySheet(context, _selectedFilter),
        backgroundColor: AppTheme.primaryAccent,
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: const Text(
          "Log Activity",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedFilter = label);
          }
        },
        selectedColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryAccent : Colors.grey.shade600,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryAccent : Colors.grey.shade200,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}

// --- FULL FEATURED BOTTOM SHEET ---

class _AddActivitySheet extends StatefulWidget {
  final String initialFilter;
  const _AddActivitySheet({required this.initialFilter});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  PlotModel? _selectedPlot;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _analysisError;

  @override
  void initState() {
    super.initState();
    // Pre-select plot if a specific filter is active
    if (widget.initialFilter != 'All') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final weatherService = context.read<WeatherSmartService>();
        final filteredPlot = weatherService.plots.firstWhere(
          (p) => p.name == widget.initialFilter,
          orElse: () => weatherService.plots.first,
        );
        setState(() => _selectedPlot = filteredPlot);
      });
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _getCropEmoji(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('maize')) return '🌽';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('nut') || lower.contains('g/nut')) return '🥜';
    return '🌱';
  }

  Future<void> _analyzeWithAI() async {
    final activity = _activityController.text.trim();
    final date = _dateController.text.trim();

    if (activity.isEmpty || _selectedPlot == null || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the details to get AI advice.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _analysisError = null;
    });

    try {
      final weatherService = context.read<WeatherSmartService>();
      final weatherData = weatherService.getPlotWeather(_selectedPlot!.id);

      if (weatherData == null) {
        throw Exception("Weather data not available for this plot yet.");
      }

      final result = await AiAdvisoryService.analyzeActivity(
        activity: activity,
        date: date,
        cropName: _selectedPlot!.cropName,
        weatherData: weatherData,
      );

      setState(() => _analysisResult = result);
    } catch (e) {
      setState(() => _analysisError = e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _saveLog() {
    final activity = _activityController.text.trim();
    final date = _dateController.text.trim();

    if (activity.isEmpty || _selectedPlot == null || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form.')),
      );
      return;
    }

    context.read<WeatherSmartService>().addLog(
      activity,
      plot: _selectedPlot!.name,
      plotId: _selectedPlot!.id,
      date: date,
      isRecommended: _analysisResult != null ? _analysisResult!['is_recommended'] : null,
      aiFeedback: _analysisResult != null ? _analysisResult!['feedback_message'] : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPlots = context.watch<WeatherSmartService>().plots;
    // Filter internal carousel plots based on initial screen filter
    final displayPlots = widget.initialFilter == 'All' 
        ? allPlots 
        : allPlots.where((p) => p.name == widget.initialFilter).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Record Activity",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Plot Carousel
                Text("Target Plot", style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayPlots.length,
                    itemBuilder: (context, index) {
                      final plot = displayPlots[index];
                      final isSelected = _selectedPlot?.id == plot.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _PlotSelectorCard(
                          plot: plot,
                          isSelected: isSelected,
                          emoji: _getCropEmoji(plot.cropName),
                          onTap: () => setState(() => _selectedPlot = plot),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Time/Date
                _DateTimeCard(
                  dateText: _dateController.text.isEmpty ? "Select Time & Date" : _dateController.text,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      if (!context.mounted) return;
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
                        final int hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
                        final String minute = pickedTime.minute.toString().padLeft(2, '0');
                        setState(() {
                          _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} at $hour:$minute $period";
                        });
                      }
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Activity Description
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    controller: _activityController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "What are you planning to do?",
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // AI Result area
                _buildAnalysisUI(),

                const SizedBox(height: 24),
                
                // Action Buttons securely inside scroll view
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeWithAI,
                        icon: const Icon(LucideIcons.sparkles, size: 20),
                        label: Text(_isAnalyzing ? "Checking..." : "Get Advice"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade50,
                          foregroundColor: Colors.indigo.shade800,
                          minimumSize: const Size(0, 64),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveLog,
                        icon: const Icon(LucideIcons.save, size: 20),
                        label: const Text("Save Log"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAccent,
                          minimumSize: const Size(0, 64),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildAnalysisUI() {
    if (_isAnalyzing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LinearProgressIndicator(color: AppTheme.primaryAccent, backgroundColor: Colors.transparent),
      );
    }
    if (_analysisError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
        child: Text(_analysisError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
      );
    }
    if (_analysisResult != null) {
      return _AdvisoryGlassCard(
        isRecommended: _analysisResult!['is_recommended'] == true,
        message: _analysisResult!['feedback_message'] ?? '',
      );
    }
    return const SizedBox.shrink();
  }
}

// --- SHARED UI COMPONENTS ---

class _PlotSelectorCard extends StatelessWidget {
  final PlotModel plot;
  final bool isSelected;
  final String emoji;
  final VoidCallback onTap;

  const _PlotSelectorCard({required this.plot, required this.isSelected, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryAccent : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              plot.name,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  final String dateText;
  final VoidCallback onTap;
  const _DateTimeCard({required this.dateText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 20, color: AppTheme.primaryAccent),
            const SizedBox(width: 16),
            Expanded(child: Text(dateText, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _AdvisoryGlassCard extends StatelessWidget {
  final bool isRecommended;
  final String message;
  const _AdvisoryGlassCard({required this.isRecommended, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = isRecommended ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.05), border: Border.all(color: color.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isRecommended ? LucideIcons.checkCircle : LucideIcons.alertTriangle, color: color, size: 20),
                  const SizedBox(width: 12),
                  Text(isRecommended ? "Recommended" : "Caution", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Text(message, style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: color.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final String cropEmoji;
  const _ActivityLogTile({required this.log, required this.cropEmoji});

  @override
  Widget build(BuildContext context) {
    final bool? isRec = log['isRecommended'];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogDetailPage(
              log: log,
              cropEmoji: cropEmoji,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.04))),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
            child: Text(cropEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['title'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                Text("${log['plot']} • ${log['time']}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isRec != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isRec ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRec ? LucideIcons.check : LucideIcons.alertTriangle,
                size: 14,
                color: isRec ? Colors.green : Colors.orange,
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.grey),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    ),
  );
}

void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Activity?"),
      content: const Text("Are you sure you want to permanently delete this farm record?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            context.read<WeatherSmartService>().deleteLog(log['id']);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Activity deleted")),
            );
          },
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}

class _EmptyLogsState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyLogsState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clipboardList, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            hasFilter ? "No logs found for this plot" : "No activities recorded yet",
            style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}