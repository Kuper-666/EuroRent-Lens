import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/analysis_record.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisRecord record;

  const ResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат анализа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Копировать',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: record.analysis));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Скопировано')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Поделиться',
            onPressed: () => Share.share(
              '${record.text}\n\n---\n\n${record.analysis}',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score badge
            if (record.score != null)
              Card(
                color: _scoreColor(record.score!),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Риск: ${record.score}/10',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (record.city != null || record.price != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (record.city != null)
                        Column(
                          children: [
                            const Icon(Icons.location_city, size: 20),
                            Text(record.city!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      if (record.price != null)
                        Column(
                          children: [
                            const Icon(Icons.euro, size: 20),
                            Text('${record.price!.round()} EUR', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Analysis text (Markdown)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MarkdownBody(
                  data: record.analysis,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, height: 1.5),
                    h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Original text (collapsible)
            ExpansionTile(
              title: const Text('Исходный текст'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    record.text,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Timestamp
            Center(
              child: Text(
                'Анализ от ${_formatDate(record.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
