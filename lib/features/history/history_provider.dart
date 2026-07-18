import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_record.dart';
import '../../data/services/database_service.dart';

class HistoryNotifier extends StateNotifier<List<AnalysisRecord>> {
  final DatabaseService _db = DatabaseService();

  HistoryNotifier() : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    state = await _db.getAllAnalyses();
  }

  Future<void> delete(String id) async {
    await _db.deleteAnalysis(id);
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> clear() async {
    await _db.clearAll();
    state = [];
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<AnalysisRecord>>(
  (ref) => HistoryNotifier(),
);
