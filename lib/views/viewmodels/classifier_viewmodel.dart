// lib/viewmodels/classifier_viewmodel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart'; //
import 'package:store_app/utils/model_helper.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/utils/location-service.dart';

class ClassifierViewModel {
  // Estados
  final PlantModel selectedModel;
  File? _image;
  List<double>? _predictions;
  bool _isLoading = false;
  bool _isUploading = false;
  Position? _location;
  String? _analysisId;

  // Callback para UI
  final Function()? onStateChanged;

  // Getters
  File? get image => _image;
  List<double>? get predictions => _predictions;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  Position? get location => _location;
  String? get analysisId => _analysisId;

  ClassifierViewModel({
    required this.selectedModel,
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
    if (_image == null || _predictions == null || _location == null) return null;

    _isUploading = true;
    _notifyListeners();

    try {
      // TODO: Llamar a tu servicio de uploadAnalysis
      // _analysisId = await PlantAnalysisService.uploadAnalysis(...);
      await Future.delayed(Duration(seconds: 2)); // Simulación
      _analysisId = 'simulated-id-123';
    } catch (e) {
      print('Error subiendo análisis: $e');
    }

    _isUploading = false;
    _notifyListeners();
    return _analysisId;
  }

  // 5. Generar análisis con IA
  Future<void> generateWithAI() async {
    if (_analysisId == null || _image == null) return;

    _isUploading = true;
    _notifyListeners();

    try {
      // TODO: Llamar a tu servicio uploadAnalysisWithAI
      await Future.delayed(Duration(seconds: 3)); // Simulación
    } catch (e) {
      print('Error generando IA: $e');
    }

    _isUploading = false;
    _notifyListeners();
  }

  // 6. Reiniciar
  void reset() {
    _image = null;
    _predictions = null;
    _analysisId = null;
    _isLoading = false;
    _isUploading = false;
    _notifyListeners();
  }

  void _notifyListeners() {
    onStateChanged?.call();
  }
}