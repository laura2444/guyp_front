// lib/viewmodels/analysis_result_viewmodel.dart

import '../../services/plant_analysis_service.dart' as PlantAnalysisService;

class AnalysisResultViewModel {
  final String analysisId;
  Map<String, dynamic>? _analysisDetails;
  bool _isLoading = false;

  final Function()? onStateChanged;

  Map<String, dynamic>? get analysisDetails => _analysisDetails;
  bool get isLoading => _isLoading;

  AnalysisResultViewModel({
    required this.analysisId,
    this.onStateChanged,
  });

  Future<void> loadAnalysisDetails() async {
    _isLoading = true;
    _notifyListeners();

    try {
      // TODO: Llamar a servicio para obtener detalles del análisis
      // _analysisDetails = await PlantAnalysisService.getAnalysis(analysisId);

      // Simulación
      await Future.delayed(Duration(seconds: 1));
      _analysisDetails = {
        'id': analysisId,
        'status': 'completado',
        'created_at': DateTime.now().toString(),
      };
    } catch (e) {
      print('Error cargando detalles: $e');
    }

    _isLoading = false;
    _notifyListeners();
  }

  Future<Map<String, dynamic>?> generateAI() async {
    _isLoading = true;
    _notifyListeners();

    try {
      final result = await PlantAnalysisService.getAnalysisAIResponse(analysisId);
      return result;
    } catch (e) {
      print('Error generando IA: $e');
      return null;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    onStateChanged?.call();
  }
}