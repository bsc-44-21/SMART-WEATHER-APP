import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../services/weather_smart_service.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All',
    'Weather Alerts',
    'Pest Detection',
    'Soil Health',
  ];

  final List<String> _adviceContent = [
    '', // Placeholder for 'All' which dynamically fetches from service
    "⚠️ Heavy rainfall expected over the next 48 hours. Ensure proper drainage in the lower sections of the plot to prevent root rot.\n\n🌡️ Temperatures are expected to drop below 10°C on Thursday night. Cover sensitive seedlings.",
    "🐛 Low risk of Fall Armyworm detected this week based on regional sensor data. Continue standard weekly scouting.\n\n🛡️ Preventative action: Consider applying neem oil spray to the perimeter of the field.",
    "🌱 Your crop's growth stage requires high nitrogen. Consider a top-dressing application of urea within the next 2 weeks.\n\n💧 Soil moisture levels are currently optimal at 68%.",
  ];

  final TextEditingController _questionController = TextEditingController();


  String _getFilteredAdvice(String fullAdvice) {
    if (_selectedFilter == 0) {
      return fullAdvice;
    }
    return _adviceContent[_selectedFilter];
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: 'plots' is available if needed for future filtering by plot
    // final plots = context.watch<WeatherSmartService>().plots;
    final aiService = context.watch<WeatherSmartService>();
    final advice = aiService.advice;
    final currentAdvice = aiService.currentAdvice;
    final isGenerating = aiService.isGeneratingAdvice;
    final displayAdvice = currentAdvice.isNotEmpty ? currentAdvice : advice;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: FarmingCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const AppLogo(
                        size: 40,
                        backgroundColor: Color(0xFFFFF9C4),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Farming Advice',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.refreshCw, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (index) {
                        final isSelected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(_filters[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? index : 0;
                              });
                            },
                            showCheckmark: false,
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _questionController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ask a farm-related question (e.g., "When should I water maize?")',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isGenerating ? null : () {
                        final query = _questionController.text.trim();
                        if (query.isNotEmpty) {
                          context.read<WeatherSmartService>().askAIQuestion(query);
                        }
                      },
                      icon: isGenerating ? const SizedBox.shrink() : const Icon(LucideIcons.messageCircle, size: 18),
                      label: isGenerating ? const Text('Generating...') : const Text('Ask AI'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _getFilteredAdvice(displayAdvice),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
