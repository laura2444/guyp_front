// lib/viewmodels/classifier_viewmodel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:store_app/utils/model_helper.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/utils/location-service.dart';
import '../../services/plant_analysis_service.dart' as PlantAnalysisService;

class ClassifierViewModel {
  // Estados
  final PlantModel selectedModel;
  final String userId; // ← AGREGADO

  File? _image;
  List<double>? _predictions;
  bool _isLoading = false;
  bool _isUploading = false;
  Position? _location;
  String? _analysisId;
  String? _aiAnalysisId;
  Map<String, dynamic>? _aiResponse;

  // Callback para UI
  final Function()? onStateChanged;

  // Getters
  File? get image => _image;
  List<double>? get predictions => _predictions;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  Position? get location => _location;
  String? get analysisId => _analysisId;
  String? get aiAnalysisId => _aiAnalysisId;
  Map<String, dynamic>? get aiResponse => _aiResponse;

  ClassifierViewModel({
    required this.selectedModel,
    required this.userId, // ← AGREGADO
    this.onStateChanged,
  });

  // 1. Obtener ubicación
  Future<void> getLocation() async {
    try {
      _location = await LocationService.getCurrentLocation();
      _notifyListeners();
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  // 2. Establecer imagen
  void setImage(File image) {
    _image = image;
    _predictions = null;
    _analysisId = null;
    _aiAnalysisId = null;
    _aiResponse = null;
    _notifyListeners();
  }

  // 3. Procesar imagen con ML
  Future<void> processImage(Uint8List imageBytes) async {
    if (_image == null) return;

    _isLoading = true;
    _notifyListeners();

    try {
      _predictions = await ModelHelper.classifyImage(
        model: selectedModel,
        imageBytes: imageBytes,
      );
    } catch (e) {
      print('Error procesando imagen: $e');
    }

    _isLoading = false;
    _notifyListeners();
  }

  // 4. Subir análisis al backend (sin IA)
  Future<String?> uploadAnalysis() async {
    if (_image == null || _predictions == null || _location == null) {
      print('❌ Faltan datos para subir análisis');
      return null;
    }

    // Validar userId
    if (userId.isEmpty) {
      print('⚠️ UserId está vacío, usando modo prueba');
      return _uploadInTestMode();
    }

    _isUploading = true;
    _notifyListeners();

    try {
      final labels = ['Bacterial', 'Fungal', 'Healthy', 'Leaf Spots', 'Viral'];
      final maxIndex = _predictions!.indexOf(_predictions!.reduce((a, b) => a > b ? a : b));
      final predictedLabel = labels[maxIndex];

      print('📤 Subiendo análisis para usuario: $userId');

      // LLAMADA REAL A TU SERVICIO
      final success = await PlantAnalysisService.uploadAnalysis(
        userId: userId,
        prediction: predictedLabel,
        lat: _location!.latitude,
        lng: _location!.longitude,
        imageFile: _image!,
      );

      if (success) {
        print('✅ Análisis subido exitosamente');
        _analysisId = 'real_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        print('❌ Error al subir análisis');
      }
    } catch (e) {
      print('💥 Excepción al subir análisis: $e');
    }

    _isUploading = false;
    _notifyListeners();
    return _analysisId;
  }

  // 4b. Modo prueba (si no hay userId válido)
  Future<String?> _uploadInTestMode() async {
    _isUploading = true;
    _notifyListeners();

    try {
      final labels = ['Bacterial', 'Fungal', 'Healthy', 'Leaf Spots', 'Viral'];
      final maxIndex = _predictions!.indexOf(_predictions!.reduce((a, b) => a > b ? a : b));
      final predictedLabel = labels[maxIndex];

      print('🧪 Modo prueba: Simulando subida de análisis');

      // Simular delay de red
      await Future.delayed(Duration(seconds: 2));

      _analysisId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ Análisis de prueba creado: $_analysisId');

    } catch (e) {
      print('Error en modo prueba: $e');
    }

    _isUploading = false;
    _notifyListeners();
    return _analysisId;
  }

  // 5. Generar análisis con IA
  Future<Map<String, dynamic>?> generateWithAI() async {
    if (_image == null || _predictions == null || _location == null) {
      print('❌ Faltan datos para generar IA');
      return null;
    }

    _isUploading = true;
    _notifyListeners();

    try {
      final labels = ['Bacterial', 'Fungal', 'Healthy', 'Leaf Spots', 'Viral'];
      final maxIndex = _predictions!.indexOf(_predictions!.reduce((a, b) => a > b ? a : b));
      final predictedLabel = labels[maxIndex];

      // LLAMADA REAL A TU SERVICIO CON IA
      final result = await PlantAnalysisService.uploadAnalysisWithAI(
        userId: userId.isEmpty ? 'test_user' : userId,
        prediction: predictedLabel,
        lat: _location!.latitude,
        lng: _location!.longitude,
        imageFile: _image!,
      );

      if (result != null) {
        _aiAnalysisId = result['id'];
        _aiResponse = result;
        print('✅ IA generada. Resultado: $result');
      } else {
        print('❌ No se pudo generar IA');
      }
    } catch (e) {
      print('💥 Error generando IA: $e');
      // Modo prueba si falla
      return _generateAITestMode();
    }

    _isUploading = false;
    _notifyListeners();
    return _aiResponse;
  }

  // 5b. Modo prueba para IA
  Future<Map<String, dynamic>> _generateAITestMode() async {
    print('🧪 Generando IA en modo prueba...');
    await Future.delayed(Duration(seconds: 3));

    final testResponse = {
      'id': 'ai_test_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Análisis con IA generado (modo prueba)',
      'ai_response': 'Esta es una respuesta simulada de IA para la predicción.',
      'summary': {
        'diagnóstico': 'Simulado',
        'recomendaciones': 'Estas son recomendaciones de prueba.',
        'tratamiento': 'Tratamiento simulado sugerido.',
      },
      'timestamp': DateTime.now().toString(),
    };

    _aiAnalysisId = testResponse['id'] as String?;
    _aiResponse = testResponse;

    _isUploading = false;
    _notifyListeners();

    return testResponse;
  }

  // 6. Obtener respuesta de IA (si ya existe)
  Future<void> fetchAIResponse(String analysisId) async {
    if (analysisId.startsWith('test_') || analysisId.startsWith('ai_test_')) {
      print('⚠️ ID de prueba, no se puede obtener respuesta real');
      return;
    }

    _isLoading = true;
    _notifyListeners();

    try {
      _aiResponse = await PlantAnalysisService.getAnalysisAIResponse(analysisId);
      if (_aiResponse != null) {
        print('✅ Respuesta de IA obtenida');
      }
    } catch (e) {
      print('Error obteniendo respuesta IA: $e');
    }

    _isLoading = false;
    _notifyListeners();
  }

  // 7. Reiniciar
  void reset() {
    _image = null;
    _predictions = null;
    _analysisId = null;
    _aiAnalysisId = null;
    _aiResponse = null;
    _isLoading = false;
    _isUploading = false;
    _notifyListeners();
  }

  void _notifyListeners() {
    onStateChanged?.call();
  }
}