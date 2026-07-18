import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/api_client.dart';
import '../../data/models/analysis_record.dart';
import '../../data/services/database_service.dart';
import '../../features/auth/auth_provider.dart';
import '../../widgets/loading_screen.dart';
import '../history/history_provider.dart';
import 'result_screen.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final String recognizedText;
  final String? imagePath;
  final double confidence;

  const AnalysisScreen({
    super.key,
    required this.recognizedText,
    this.imagePath,
    required this.confidence,
  });

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  late TextEditingController _textController;
  bool _isSending = false;
  String _selectedLang = 'ru';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recognizedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendForAnalysis() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите текст объявления')),
      );
      return;
    }

    // Переходим на экран загрузки — там вся логика отправки и ожидания
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(
          text: text,
          imagePath: widget.imagePath,
          lang: _selectedLang,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (lang) => setState(() => _selectedLang = lang),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
              const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              const PopupMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
              const PopupMenuItem(value: 'uk', child: Text('🇺🇦 Українська')),
              const PopupMenuItem(value: 'it', child: Text('🇮🇹 Italiano')),
              const PopupMenuItem(value: 'pl', child: Text('🇵🇱 Polski')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedLang.toUpperCase()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo preview
            if (widget.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              if (!widget.confidence.isNaN)
                LinearProgressIndicator(
                  value: widget.confidence,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              const SizedBox(height: 16),
            ],

            // OCR confidence indicator
            if (!widget.confidence.isNaN)
              Chip(
                avatar: Icon(
                  widget.confidence >= 0.7 ? Icons.check_circle : Icons.warning,
                  color: widget.confidence >= 0.7 ? Colors.green : Colors.orange,
                  size: 18,
                ),
                label: Text(
                  'Точность распознавания: ${(widget.confidence * 100).round()}%',
                ),
              ),

            const SizedBox(height: 16),

            // Text editor
            Text(
              'Распознанный текст:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 15,
              minLines: 8,
              decoration: const InputDecoration(
                hintText: 'Текст объявления...',
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            // Send button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendForAnalysis,
                child: _isSending
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Отправляю боту...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Отправить боту для анализа'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
