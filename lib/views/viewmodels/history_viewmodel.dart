// lib/viewmodels/history_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:store_app/models/plant_analysis_model.dart';
import 'package:store_app/services/plant_analysis_service.dart';
import 'package:store_app/services/secure_storage_service.dart';

import '../../services/plant_analysis_service.dart' as PlantAnalysisService;

class HistoryViewModel with ChangeNotifier {
  List<PlantAnalysisModel> _analyses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PlantAnalysisModel> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _analyses.isEmpty && !_isLoading;

  // Cargar análisis
  Future<void> loadAnalyses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await SecureStorageService().getUserSession();
      final userId = session['user_id'];

      if (userId == null || userId.isEmpty) {
        _error = 'No hay sesión activa';
        _analyses = [];
      } else {
        _analyses = await getUserAnalyses(userId);
      }
    } catch (e) {
      _error = 'Error al cargar análisis: $e';
      _analyses = [];
      debugPrint('HistoryViewModel Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Eliminar un análisis
  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      final success = await PlantAnalysisService.deleteAnalysis(analysisId);

      if (success) {
        _analyses.removeWhere((analysis) => analysis.id == analysisId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al eliminar análisis: $e';
      notifyListeners();
      return false;
    }
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadAnalyses();
  }

  // Obtener análisis por ID
  PlantAnalysisModel? getAnalysisById(String id) {
    return _analyses.firstWhere((analysis) => analysis.id == id);
  }

  // Filtrar por tipo de planta
  List<PlantAnalysisModel> filterByPlantType(String plantType) {

    return _analyses
        .where((analysis) => analysis.plantType == plantType)
        .toList();
  }

  // Obtener análisis recientes
  List<PlantAnalysisModel> get recentAnalyses {
    final sorted = List<PlantAnalysisModel>.from(_analyses);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  // Obtener análisis con IA generada
  List<PlantAnalysisModel> get analysesWithAI {
    return _analyses.where((analysis) => analysis.aiGenerated == true).toList();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}