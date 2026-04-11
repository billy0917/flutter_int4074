import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/recognition_result.dart';
import '../models/learning_record.dart';
import '../providers/history_provider.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/clay_button.dart';
import '../widgets/loading_animation.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import '../config/api_config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  bool _isLoading = false;
  String? _error;
  ModelPreset _selectedPreset = ModelPreset.stable;
  final _imageService = ImageService();

  Future<void> _pickImage(ImageSource source) async {
    File? file;
    if (source == ImageSource.camera) {
      file = await _imageService.pickFromCamera();
    } else {
      file = await _imageService.pickFromGallery();
    }
    if (file != null) {
      setState(() {
        _image = file;
        _error = null;
      });
    }
  }

  Future<void> _recognize() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Save image locally
      final savedPath = await _imageService.saveImageLocally(_image!);

      final result = await ApiService.recognizeObject(_image!, preset: _selectedPreset);

      final withPath = result!.copyWith(imagePath: savedPath ?? _image!.path);

      // Save to history
      final record = _buildRecord(withPath, savedPath ?? _image!.path);
      await context.read<HistoryProvider>().addRecord(record);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushNamed(
        context,
        AppRoutes.result,
        arguments: {'result': withPath, 'preset': _selectedPreset},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Show the full exception message so the real cause is visible
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  LearningRecord _buildRecord(RecognitionResult r, String imagePath) {
    final rec = LearningRecord()
      ..id = const Uuid().v4()
      ..imagePath = imagePath
      ..objectNameZh = r.objectNameZh
      ..objectNameEn = r.objectNameEn
      ..pinyin = r.pinyin
      ..pinyinNoTone = r.pinyinNoTone
      ..characters = r.characters
          .map((c) => CharacterToneHive()
            ..char = c.char
            ..pinyin = c.pinyin
            ..toneNumber = c.toneNumber
            ..toneNameZh = c.toneNameZh
            ..toneNameEn = c.toneNameEn)
          .toList()
      ..cantoneseReference = r.cantoneseReference
      ..exampleSentenceZh = r.exampleSentenceZh
      ..exampleSentencePinyin = r.exampleSentencePinyin
      ..exampleSentenceEn = r.exampleSentenceEn
      ..createdAt = DateTime.now()
      ..quizAttempts = [];
    return rec;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.cameraTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library_rounded,
                color: AppColors.primary),
            label: Text(l.cameraAlbum,
                style: const TextStyle(color: AppColors.primary)),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            children: [
              // Model selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ModelPreset.values.map((preset) {
                    final selected = _selectedPreset == preset;
                    final cfg = ApiConfig.getConfig(preset);
                    final isStable = preset == ModelPreset.stable;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPreset = preset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isStable ? Icons.verified_rounded : Icons.bolt_rounded,
                                size: 16,
                                color: selected ? Colors.white : AppColors.textMedium,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isStable
                                    ? (l.cameraModelStable)
                                    : (l.cameraModelFast),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  color: selected ? Colors.white : AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              // Image preview
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcons.svg(AppIcons.camera, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                l.cameraHint,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                LoadingAnimation(message: l.loadingRecognize)
              else ...[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.modelSwitchHint,
                          style: const TextStyle(
                              color: AppColors.textLight, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                if (_image == null)
                  // Take photo button
                  ClayButton(
                    color: AppColors.primary,
                    width: double.infinity,
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded,
                            color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          l.cameraTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  ClayButton(
                    color: AppColors.primary,
                    width: double.infinity,
                    onTap: _recognize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcons.svg(AppIcons.rocket, size: 22, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          l.cameraRecognize,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClayButton(
                    color: AppColors.cardBgAlt,
                    width: double.infinity,
                    onTap: () => setState(() {
                      _image = null;
                      _error = null;
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            color: AppColors.textMedium),
                        const SizedBox(width: 10),
                        Text(
                          l.cameraRetake,
                          style: const TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageSource { camera, gallery }
