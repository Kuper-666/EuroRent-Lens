import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/ocr_service.dart';
import '../analysis/analysis_screen.dart';

// OCR доступен только на мобильных платформах
// На web — пользователь вводит текст вручную
const bool _isMobile = !kIsWeb;

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    if (_isMobile) {
      // На мобильных — камера
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (photo != null) {
        await _processImageMobile(photo.path);
      }
    } else {
      // На web — загрузка файла
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        // На web OCR недоступен — переходим к ручному вводу
        _showManualInput();
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      if (_isMobile) {
        await _processImageMobile(image.path);
      } else {
        _showManualInput();
      }
    }
  }

  Future<void> _processImageMobile(String imagePath) async {
    setState(() => _isProcessing = true);
    try {
      // OCR доступен только на мобильных
      // ignore: avoid_dynamic_calls
      final ocrResult = await _recognizeTextMobile(imagePath);

      if (!mounted) return;

      if (ocrResult.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Текст на фото не распознан')),
        );
        setState(() => _isProcessing = false);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            recognizedText: ocrResult,
            imagePath: imagePath,
            confidence: 0.85,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _recognizeTextMobile(String imagePath) async {
    // Импорт ML Kit только на мобильных платформах
    if (kIsWeb) return '';
    try {
      // ignore: depend_on_referenced_packages
      // ignore: avoid_dynamic_calls
      final result = await _callOcrService(imagePath);
      return result;
    } catch (e) {
      return '';
    }
  }

  Future<String> _callOcrService(String imagePath) async {
    if (kIsWeb) return '';
    try {
      final ocrService = OcrService();
      final result = await ocrService.recognizeText(File(imagePath));
      ocrService.dispose();
      return result.fullText;
    } catch (e) {
      return '';
    }
  }

  void _showManualInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalysisScreen(
          recognizedText: '',
          confidence: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить объявление')),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Распознаю текст...'),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      kIsWeb ? Icons.upload_file : Icons.camera_alt,
                      size: 120,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 32),
                    if (!kIsWeb)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Сфотографировать'),
                        ),
                      ),
                    if (!kIsWeb) const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: Icon(kIsWeb ? Icons.upload : Icons.photo_library),
                        label: Text(kIsWeb ? 'Загрузить фото' : 'Выбрать из галереи'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // На web — кнопка ручного ввода
                    if (kIsWeb)
                      TextButton.icon(
                        onPressed: _showManualInput,
                        icon: const Icon(Icons.edit),
                        label: const Text('Ввести текст вручную'),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      kIsWeb
                          ? 'Загрузите фото или введите текст объявления'
                          : 'Сфотографируйте объявление об аренде',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
