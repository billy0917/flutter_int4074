enum ModelPreset {
  fast,
  stable,
}

class ModelConfig {
  final String label;
  final String apiKey;
  final String model;

  const ModelConfig({
    required this.label,
    required this.apiKey,
    required this.model,
  });
}

class ApiConfig {
  static const String baseUrl =
      'https://api.apiplus.org/v1/chat/completions';

  static const _configs = {
    ModelPreset.fast: ModelConfig(
      label: '快速',
      apiKey: 'your_fast_api_key',
      model: 'gemini-3.1-flash-lite-preview',
    ),
    ModelPreset.stable: ModelConfig(
      label: '穩定（較慢）',
      apiKey: 'your_stable_api_key',
      model: 'qwen3-vl-235b-a22b-instruct',
    ),
  };

  static ModelConfig getConfig(ModelPreset preset) => _configs[preset]!;

  // Default config for non-camera usage (quiz, TTS, etc.)
  static String get apiKey => _configs[ModelPreset.fast]!.apiKey;
  static String get model => _configs[ModelPreset.fast]!.model;
}
