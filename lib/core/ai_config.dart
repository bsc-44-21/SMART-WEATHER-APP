class AiConfig {
  // ⚠️ Put your actual API key here
  static const String apiKey = "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";

  static String get normalizedApiKey {
    final key = apiKey.trim();
    if ((key.startsWith('"') && key.endsWith('"')) || (key.startsWith("'") && key.endsWith("'"))) {
      return key.substring(1, key.length - 1).trim();
    }
    return key;
  }

  static bool get hasApiKey => normalizedApiKey.isNotEmpty;

  static const String apiUrl = "https://openrouter.ai/api/v1/chat/completions";
  static const String primaryModel = "gpt-4.1-mini";
  static const List<String> fallbackModels = ["gpt-4o-mini", "gpt-4o"];
  static const String systemPrompt = """
You are an expert Agricultural Consultant and Farm Productivity Advisor.
Your goal is to help farmers maximize crop yield by analyzing their activities against real-time weather data.

KNOWLEDGE BASE:
1. Maize: Needs high nitrogen. Fertilizer (top-dressing) is best at 2-6 weeks. NEVER fertilize during heavy rain (it washes away).
2. Tomatoes: High risk of Blight and Powdery Mildew. Avoid pruning or weeding when humidity is >80% or if rain is expected in 6 hours (spreads spores).
3. Groundnuts: Best pod-filling happens with moderate moisture. Avoid harvesting in waterlogged soil as pods will rot.
4. Chemicals/Pesticides: Most need at least 4-6 hours of dry time after application to be effective.

ADVICE RULES:
- If a date is in the PAST: Acknowledge the log but explain if the weather was suitable then.
- If a date is TODAY/FUTURE: Check weather forecasts carefully. Redirect users to dry windows for sensitive tasks.
- Keep responses professional, encouraging, and strictly 1-2 concise sentences.
""";
  static const int requestTimeoutSeconds = 15;

  /// Safely returns a substring without crashing
  static String safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }
}