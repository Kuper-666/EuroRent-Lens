import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network/api_client.dart';
import '../data/models/analysis_record.dart';
import '../data/services/database_service.dart';
import '../features/analysis/result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String text;
  final String? imagePath;
  final String lang;

  const LoadingScreen({
    super.key,
    required this.text,
    this.imagePath,
    this.lang = 'ru',
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _elapsed = 0;
  Timer? _timer;
  String _status = 'Отправляю объявление боту...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _elapsed++);
      if (_elapsed == 5) _status = 'Бот анализирует объявление...';
      if (_elapsed == 15) _status = 'Проверяю цены и риски...';
      if (_elapsed == 30) _status = 'Почти готово...';
    });

    _sendAnalysis();
  }

  Future<void> _sendAnalysis() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.analyzeListing(
        text: widget.text,
        userId: 'app_user',
        lang: widget.lang,
      );

      final record = AnalysisRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: widget.text,
        analysis: response.analysis,
        imagePath: widget.imagePath,
        city: response.city,
        price: response.price,
        score: response.score,
        createdAt: DateTime.now(),
      );

      await DatabaseService().insertAnalysis(record);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.1),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.home_work,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 48),

              // Progress indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              // Status text
              Text(
                _status,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Timer
              Text(
                '${_elapsed}с',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // Cancel button
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
