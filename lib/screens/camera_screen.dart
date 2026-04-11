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
import '../utils/responsive.dart';
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
          padding: const EdgeInsets.symmetric(vertical: AppConstants.pagePadding),
          child: Column(
            children: [
              // Model selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
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
              ),
              const SizedBox(height: 12),
              // Image preview with focus frame
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                  children: [
                      // Main image container
                      Positioned.fill(
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
                              ? Image.file(_image!, fit: BoxFit.cover,
                                  width: double.infinity, height: double.infinity)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Camera icon with pink circle + drop shadow
                                    Container(
                                      width: context.s(100),
                                      height: context.s(100),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color.fromRGBO(255, 140, 66, 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD6E0).withValues(alpha: 0.5),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 6),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AppIcons.svg(AppIcons.camera,
                                            size: context.s(48), color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l.cameraHint,
                                      style: TextStyle(
                                        fontSize: context.sp(18),
                                        color: AppColors.textMedium,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      ),
                      // Focus frame corners with glow
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _FocusFramePainter(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                              cornerLength: 28,
                              cornerRadius: AppConstants.cardRadius,
                              glowColor: AppColors.primary.withValues(alpha: 0.35),
                              glowWidth: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              const SizedBox(height: 24),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: LoadingAnimation(message: l.loadingRecognize),
                )
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClayButton(
                      color: const Color.fromRGBO(255, 140, 66, 1),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClayButton(
                      color: AppColors.primary,
                      width: double.infinity,
                      onTap: _recognize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcons.svg(AppIcons.rocket, size: context.s(22), color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            l.cameraRecognize,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClayButton(
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

// ─────────────────────────────────────────────────────────
//  「」Focus frame corner painter with glow
// ─────────────────────────────────────────────────────────

class _FocusFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double cornerRadius;
  final Color glowColor;
  final double glowWidth;

  _FocusFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.cornerRadius,
    required this.glowColor,
    required this.glowWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Glow paint (drawn first, behind)
    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = strokeWidth + glowWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowWidth);

    // Main line paint
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final cl = cornerLength;

    for (final paint in [glowPaint, linePaint]) {
      // Top-left corner 「
      final tl = Path()
        ..moveTo(0, cl)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(cl, 0);
      canvas.drawPath(tl, paint);

      // Top-right corner
      final tr = Path()
        ..moveTo(w - cl, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, cl);
      canvas.drawPath(tr, paint);

      // Bottom-left corner
      final bl = Path()
        ..moveTo(0, h - cl)
        ..lineTo(0, h - r)
        ..quadraticBezierTo(0, h, r, h)
        ..lineTo(cl, h);
      canvas.drawPath(bl, paint);

      // Bottom-right corner 」
      final br = Path()
        ..moveTo(w - cl, h)
        ..lineTo(w - r, h)
        ..quadraticBezierTo(w, h, w, h - r)
        ..lineTo(w, h - cl);
      canvas.drawPath(br, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusFramePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
