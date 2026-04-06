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
  static const String systemPrompt = "You are an agriculture assistant.";
  static const int requestTimeoutSeconds = 15;

  /// Safely returns a substring without crashing
  static String safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }
}