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
  final List<String> _filters = ['All', 'Weather Alerts', 'Pest Detection', 'Soil Health'];

   final List<String> _adviceContent = [
    '', // Placeholder for 'All' which dynamically fetches from service
    "⚠️ Heavy rainfall expected over the next 48 hours. Ensure proper drainage in the lower sections of the plot to prevent root rot.\n\n🌡️ Temperatures are expected to drop below 10°C on Thursday night. Cover sensitive seedlings.",
    "🐛 Low risk of Fall Armyworm detected this week based on regional sensor data. Continue standard weekly scouting.\n\n🛡️ Preventative action: Consider applying neem oil spray to the perimeter of the field.",
    "🌱 Your crop's growth stage requires high nitrogen. Consider a top-dressing application of urea within the next 2 weeks.\n\n💧 Soil moisture levels are currently optimal at 68%.",
  ];

  String _getFilteredAdvice(String fullAdvice) {
    if (_selectedFilter == 0) {
      return fullAdvice;
    }
    return _adviceContent[_selectedFilter];
  }

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<WeatherSmartService>().plots;
    final advice = context.watch<WeatherSmartService>().advice;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (plots.isNotEmpty)
            PlotInfoCard(
              plot: plots[0],
            ),