// lib/viewmodels/classifier_viewmodel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/utils/location-service.dart';
import '../../services/plant_analysis_service.dart' as PlantAnalysisService;
import '../../models/plant_analysis_model.dart';

class ClassifierViewModel {
  // Estados
  final String userId;
  String plantType = 'tomato'; // 'tomato', 'potato', 'pepper' - NUEVO
  PlantModel? selectedModel; // Ahora nullable

  File? _image;
  List<double>? _predictions;
  bool _isLoading = false;
  bool _isUploading = false;
  Position? _location;
  String? _analysisId;
  PlantAnalysisModel? _currentAnalysis; // NUEVO
  AIAnalysisResponse? _aiAnalysis; // NUEVO

  // Callback para UI
  final Function()? onStateChanged;

  // Getters
  File? get image => _image;
  List<double>? get predictions => _predictions;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  Position? get location => _location;
  String? get analysisId => _analysisId;
  PlantAnalysisModel? get currentAnalysis => _currentAnalysis;
  AIAnalysisResponse? get aiAnalysis => _aiAnalysis;
  String get confidencePercentage {
    if (_currentAnalysis?.confidence != null) {
      return '${(_currentAnalysis!.confidence * 100).toStringAsFixed(1)}%';
    }
    return '';
  }

  ClassifierViewModel({
    required this.userId,
    this.plantType = 'tomato',
    this.onStateChanged,
  }) {
    // Mapear plantType a PlantModel para compatibilidad
    selectedModel = _getPlantModelFromType(plantType);
  }

  // 1. Obtener ubicación
  Future<void> getLocation() async {
    try {
      _location = await LocationService.getCurrentLocation();
      _notifyListeners();
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  // 2. Cambiar tipo de planta
  void setPlantType(String type) {
    plantType = type;
    selectedModel = _getPlantModelFromType(type);
    _notifyListeners();
  }

  // 3. Establecer imagen
  void setImage(File image) {
    _image = image;
    _predictions = null;
    _analysisId = null;
    _currentAnalysis = null;
    _aiAnalysis = null;
    _notifyListeners();
  }

  // 4. Procesar imagen con API (ya no con TFLite local)
  Future<void> processImage() async {
    if (_image == null) return;

    _isLoading = true;
    _notifyListeners();

    try {
      // Aquí podrías mostrar preview mientras se sube
      print('📤 Subiendo imagen para análisis...');

      // La API ahora hace toda la predicción
      // Solo preparamos para subir
      _predictions = [0.0]; // Placeholder

    } catch (e) {
      print('Error procesando imagen: $e');
    }

    _isLoading = false;
    _notifyListeners();
  }

  // 5. Subir análisis al backend (sin IA)
  Future<PlantAnalysisModel?> uploadAnalysis() async {
    if (_image == null || _location == null) {
      print('❌ Faltan imagen o ubicación');
      return null;
    }

    _isUploading = true;
    _notifyListeners();

    try {
      print('📤 Subiendo análisis para $plantType...');

      // LLAMADA A LA NUEVA API
      final response = await PlantAnalysisService.uploadAnalysis(
        plantType: plantType,
        userId: userId,
        lat: _location!.latitude,
        lng: _location!.longitude,
        imageFile: _image!,
      );

      if (response != null) {
        print('✅ Análisis subido exitosamente');

        // Crear modelo con la respuesta
        _currentAnalysis = PlantAnalysisModel(
          id: response['analysis_id'] ?? '',
          userId: userId,
          plantType: plantType,
          prediction: response['prediction'] ?? 'Desconocido',
          classId: response['class_id']?.toInt(),
          confidence: (response['confidence'] ?? 0.0).toDouble(),
          location: {'lat': _location!.latitude, 'lng': _location!.longitude},
          imageId: '', // Se necesita obtener de otra forma
          createdAt: DateTime.now(),
        );

        _analysisId = _currentAnalysis!.id;

        print('📊 Resultado: ${_currentAnalysis!.prediction} '
            '(${(_currentAnalysis!.confidence * 100).toStringAsFixed(1)}%)');
      } else {
        print('❌ Error al subir análisis');
      }
    } catch (e) {
      print('💥 Excepción al subir análisis: $e');
      _currentAnalysis = null;
    }

    _isUploading = false;
    _notifyListeners();
    return _currentAnalysis;
  }

  // 6. Generar análisis con IA
  Future<AIAnalysisResponse?> generateWithAI() async {
    if (_image == null || _location == null) {
      print('❌ Faltan imagen o ubicación');
      return null;
    }

    _isUploading = true;
    _notifyListeners();

    try {
      print('🤖 Generando análisis con IA para $plantType...');

      // LLAMADA A LA NUEVA API CON IA
      final result = await PlantAnalysisService.uploadAnalysisWithAI(
        plantType: plantType,
        userId: userId,
        lat: _location!.latitude,
        lng: _location!.longitude,
        imageFile: _image!,
      );

      if (result != null) {
        print('✅ IA generada exitosamente');

        // Crear respuesta AI
        _aiAnalysis = AIAnalysisResponse.fromJson(result);

        // También crear análisis completo
        _currentAnalysis = _aiAnalysis!.toPlantAnalysisModel(
          userId: userId,
          location: {'lat': _location!.latitude, 'lng': _location!.longitude},
          imageId: '', // Se necesita obtener
        );

        _analysisId = _aiAnalysis!.analysisId;

        print('📊 Resultado IA: ${_aiAnalysis!.prediction} '
            '(${(_aiAnalysis!.confidence * 100).toStringAsFixed(1)}%)');
      } else {
        print('❌ No se pudo generar IA');
      }
    } catch (e) {
      print('💥 Error generando IA: $e');
      _aiAnalysis = null;
    }

    _isUploading = false;
    _notifyListeners();
    return _aiAnalysis;
  }

  // 7. Obtener análisis por ID
  Future<PlantAnalysisModel?> fetchAnalysis(String analysisId) async {
    _isLoading = true;
    _notifyListeners();

    try {
      _currentAnalysis = await PlantAnalysisService.getAnalysis(analysisId);
      if (_currentAnalysis != null) {
        print('✅ Análisis obtenido: ${_currentAnalysis!.prediction}');
        _analysisId = analysisId;
      }
    } catch (e) {
      print('Error obteniendo análisis: $e');
      _currentAnalysis = null;
    }

    _isLoading = false;
    _notifyListeners();
    return _currentAnalysis;
  }

  // 8. Obtener respuesta de IA para un análisis existente
  Future<void> fetchAIResponse(String analysisId) async {
    _isLoading = true;
    _notifyListeners();

    try {
      final response = await PlantAnalysisService.getAnalysisAIResponse(analysisId);
      if (response != null) {
        // Actualizar el análisis actual con la respuesta AI
        if (_currentAnalysis != null && _currentAnalysis!.id == analysisId) {
          _currentAnalysis = _currentAnalysis!.copyWith(
            aiResponse: response['ai_response'],
            aiGenerated: true,
          );
        }
        print('✅ Respuesta de IA obtenida');
      }
    } catch (e) {
      print('Error obteniendo respuesta IA: $e');
    }

    _isLoading = false;
    _notifyListeners();
  }

  // 9. Reiniciar
  void reset() {
    _image = null;
    _predictions = null;
    _analysisId = null;
    _currentAnalysis = null;
    _aiAnalysis = null;
    _isLoading = false;
    _isUploading = false;
    _notifyListeners();
  }

  // 10. Utilerías
  PlantModel _getPlantModelFromType(String type) {
    switch (type.toLowerCase()) {
      case 'tomato':
        return PlantModel.tomato;
      case 'potato':
        return PlantModel.potato;
      case 'pepper':
        return PlantModel.pepper;
      default:
        return PlantModel.tomato;
    }
  }

  // Obtener nombre amigable de la planta
  String get plantDisplayName {
    switch (plantType) {
      case 'tomato':
        return 'Tomate';
      case 'potato':
        return 'Papa';
      case 'pepper':
        return 'Pimiento';
      default:
        return 'Tomate';
    }
  }

  // Verificar si el análisis actual es de una planta sana
  bool get isCurrentAnalysisHealthy {
    return _currentAnalysis?.isHealthy ?? false;
  }

  void _notifyListeners() {
    onStateChanged?.call();
  }
}