// lib/viewmodels/history_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:store_app/models/plant_analysis_model.dart';
import 'package:store_app/services/plant_analysis_service.dart'
as PlantAnalysisService;
import 'package:store_app/services/secure_storage_service.dart';

class HistoryViewModel with ChangeNotifier {
  // ================== STATE ==================

  final List<PlantAnalysisModel> _analyses = [];

  bool _isLoading = false;
  String? _error;

  String? _activePlantFilter; // tomato | potato | pepper

  // ================== GETTERS ==================

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _analyses.isEmpty && !_isLoading;

  String? get activePlantFilter => _activePlantFilter;

  List<PlantAnalysisModel> get analyses =>
      List.unmodifiable(_analyses);

  /// Lista filtrada (reactiva)
  List<PlantAnalysisModel> get filteredAnalyses {
    final base = recentAnalyses;

    if (_activePlantFilter == null) return base;

    return base
        .where((a) => a.plantType == _activePlantFilter)
        .toList();
  }

  // ================== DATA ==================

  Future<void> loadAnalyses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await SecureStorageService().getUserSession();
      final userId = session['user_id'];

      if (userId == null || userId.isEmpty) {
        _analyses.clear();
        _error = 'No hay sesión activa';
      } else {
        final data =
        await PlantAnalysisService.getUserAnalyses(userId);

        _analyses
          ..clear()
          ..addAll(data);
      }
    } catch (e) {
      _analyses.clear();
      _error = 'Error al cargar análisis';
      debugPrint('HistoryViewModel.loadAnalyses → $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async => loadAnalyses();

  // ================== DELETE ==================

  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      final success =
      await PlantAnalysisService.deleteAnalysis(analysisId);

      if (success) {
        _analyses.removeWhere((a) => a.id == analysisId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al eliminar análisis';
      debugPrint('HistoryViewModel.deleteAnalysis → $e');
      notifyListeners();
      return false;
    }
  }

  // Análisis que sí tienen resultado de IA
  List<PlantAnalysisModel> get analysesWithAI {
    return _analyses.where((a) => a.aiGenerated).toList();
  }

  // ================== FILTERS ==================

  void setPlantFilter(String? plantType) {
    _activePlantFilter = plantType;
    notifyListeners();
  }

  void clearFilters() {
    _activePlantFilter = null;
    notifyListeners();
  }

  // ================== HELPERS ==================

  /// Análisis recientes
  List<PlantAnalysisModel> get recentAnalyses {
    final sorted = List<PlantAnalysisModel>.from(_analyses);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Obtener análisis por ID (seguro)
  PlantAnalysisModel? getAnalysisById(String id) {
    try {
      return _analyses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }


  /// Resultado principal IA (SEGURO)
  String getMainAIResult(PlantAnalysisModel analysis) {
    final ai = analysis.aiResponse;

    if (ai == null || ai.isEmpty) {
      return 'Sin resultado';
    }

    return ai['diagnosis'] ??
        ai['label'] ??
        ai['result'] ??
        'Resultado no disponible';
  }

  /// Confianza IA (si existe)
  double? getAIConfidence(PlantAnalysisModel analysis) {
    final ai = analysis.aiResponse;

    if (ai == null) return null;

    final value = ai['confidence'];
    return value is num ? value.toDouble() : null;
  }

  // ================== ERROR ==================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// URL de imagen lista para usar en vistas
  String? getImageUrlForAnalysis(PlantAnalysisModel analysis) {
    final imageId = analysis.imageId;

    if (imageId == null || imageId.isEmpty) {
      debugPrint('🖼️ [HistoryVM] imageId null o vacío');
      return null;
    }

    final url = PlantAnalysisService.getImageUrl(imageId);
    debugPrint('🖼️ [HistoryVM] imageUrl: $url');
    return url;
  }

}
