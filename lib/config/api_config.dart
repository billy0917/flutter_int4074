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
      apiKey: 'your api key',
      model: 'your api',
    ),
    ModelPreset.stable: ModelConfig(
      label: '穩定（較慢）',
      apiKey: 'your api key',
      model: 'your api',
    ),
  };

  static ModelConfig getConfig(ModelPreset preset) => _configs[preset]!;

  // Default config for non-camera usage (quiz, TTS, etc.)
  static String get apiKey => _configs[ModelPreset.fast]!.apiKey;
  static String get model => _configs[ModelPreset.fast]!.model;
}
