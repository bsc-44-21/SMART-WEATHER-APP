import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/secrets.dart';

class AiAdvisoryService {
  static const String _apiKey = AppSecrets.geminiKey;

  static Future<Map<String, dynamic>> analyzeActivity({
    required String activity,
    required String date,
    required String cropName,
    required Map<String, dynamic> weatherData,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Missing Gemini API Key. Please add it in lib/services/ai_advisory_service.dart');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'is_recommended': Schema.boolean(
                description: 'Whether the activity is recommended based on the weather.',
              ),
              'feedback_message': Schema.string(
                description: 'Explanation for recommendation or warning, using specific weather data context.',
              ),
            },
            requiredProperties: ['is_recommended', 'feedback_message'],
          ),
        ),
      );

      final prompt = '''
You are a highly specialized agricultural AI advisor.
IMPORTANT: You are strictly restricted to only providing advice for these three crops: Maize, Tomato, and Groundnuts (g/nuts).

This plot is explicitly planted with "$cropName".

CRITICAL CROP RESTRICTION: 
If "$cropName" is NOT Maize, Tomato, or Groundnuts/G.nuts, you MUST reject the request. 
In that case, set "is_recommended": false, and set "feedback_message" to: "I am currently specialized to provide advice ONLY for Maize, Tomato, and Groundnuts. I cannot analyze activities for '$cropName' at this time."

If the crop is valid, tailor your weather analysis and agriculture logic specifically to the vulnerability and growth needs of "$cropName".

The user wants to carry out the following activity on their farm plot:
- Activity: "$activity"
- Target Time/Date: $date

CRITICAL ACTIVITY INSTRUCTION: If the requested activity ("$activity") is NOT related to agriculture, farming, or managing crops, you MUST reject the request. 
In that case, set "is_recommended": false, and set "feedback_message" to: "I am a specialized AI for agricultural purposes only. Please provide a farming-related activity."

If the activity IS related to agriculture and the crop is supported, look at the weather forecasts.
Here is the robust weather forecast data for this exact plot:
${jsonEncode(weatherData)}

CRITICAL WEATHER ANALYSIS INSTRUCTION:
The weather data provided above contains both "hourly" and "daily" arrays. 
- If the user specifies a specific time of day in their activity or date (e.g., "4:30 PM", "tonight"), you MUST look at the specific hours in the "hourly" array to ensure conditions (rain, temperature) are safe at that exact time for "$cropName".
- If they specify a broader timeframe like "tomorrow", "day after tomorrow", or "next week", use the "daily" (24hrs/weekly) predictions. 

Analyze the weather and determine if it is safe, optimal, or risky to perform this agricultural activity for this crop.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        return data;
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      throw Exception('Failed to analyze activity: $e');
    }
  }

  static Future<Map<String, dynamic>> getPestReportFromImage({
    required File imageFile,
    required String cropName,
    String? weatherSummary,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Missing Gemini API Key.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'is_valid': Schema.boolean(description: 'Whether the image is a valid crop/pest photo for the selected crop'),
              'rejection_reason': Schema.string(description: 'Reason why the image is invalid (e.g., "Not a tomato plant")'),
              'pest_name': Schema.string(),
              'signs_symptoms': Schema.array(items: Schema.string()),
              'bad_impact': Schema.string(),
              'natural_recommendations': Schema.array(items: Schema.string()),
              'chemical_recommendations': Schema.array(items: Schema.string()),
              'risk_level': Schema.string(description: 'High, Medium, or Low'),
              'smart_weather_advice': Schema.string(description: 'Advice on whether weather affects treatment (e.g., dont spray if rain is coming)'),
            },
            requiredProperties: [
              'is_valid',
              'pest_name',
              'signs_symptoms',
              'bad_impact',
              'natural_recommendations',
              'chemical_recommendations',
              'risk_level'
            ],
          ),
        ),
      );

      final prompt = '''
You are an expert agricultural AI specializing in Malawian crops (Maize, Tomato, Groundnuts). 
I am attaching an image of a leaf/plant. 
The user has selected the crop: "$cropName". 
${weatherSummary != null ? "Upcoming Weather Forecast: $weatherSummary" : ""}

CRITICAL VALIDATION STEP: 
1. First, check if the image is actually a plant or a crop relevant to "$cropName". 
2. If the image is a person, car, dog, or an unrelated plant (e.g., a rose or a tree), you must set "is_valid": false and set "rejection_reason" to a clear explanation for the farmer.
3. If the image is valid and shows the crop or a pest on it, set "is_valid": true.

If "is_valid" is true, please:
1. Identify the pest or disease in the image.
2. Provide a detailed agricultural report:
   - "pest_name": The confirmed name of the pest/disease.
   - "signs_symptoms": Typical signs it leaves on "$cropName".
   - "bad_impact": The impact on Malawian farm yield.
   - "natural_recommendations": Organic control available in Malawi (e.g., neem oil, ash).
   - "chemical_recommendations": Chemical control available in Malawi.
   - "risk_level": High, Medium, or Low.
   - "smart_weather_advice": IMPORTANT: Look at the upcoming weather. If rain is expected, warn the farmer NOT to apply chemical pesticides as they will be washed away. Mention the specific weather condition.

Respond ONLY in JSON format.
''';

      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanJson);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  static Future<Map<String, dynamic>> getPestAdvice({
    required String pestName,
    required String cropName,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Missing Gemini API Key.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'pest_name': Schema.string(),
              'signs_symptoms': Schema.array(items: Schema.string()),
              'bad_impact': Schema.string(),
              'natural_recommendations': Schema.array(items: Schema.string()),
              'chemical_recommendations': Schema.array(items: Schema.string()),
              'risk_level': Schema.string(description: 'High, Medium, or Low'),
            },
            requiredProperties: [
              'pest_name',
              'signs_symptoms',
              'bad_impact',
              'natural_recommendations',
              'chemical_recommendations',
              'risk_level'
            ],
          ),
        ),
      );

      final prompt = '''
You are an expert agricultural AI specializing in Malawian crops. 
The AI system has detected the pest "$pestName" on a "$cropName" plant.

Please provide a detailed agricultural report focused on this pest:
1. Confirm the typical signs and symptoms it leaves on "$cropName".
2. Describe the bad impact it has on the yield.
3. Provide Natural/Organic control recommendations available in Malawi (e.g., Neem oil, ash, specific intercropping).
4. Provide Chemical control recommendations available in Malawian agro-dealers (e.g., Farmers World, Agora).

Respond ONLY in JSON format.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanJson);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      throw Exception('Failed to get pest advice: $e');
    }
  }
}
