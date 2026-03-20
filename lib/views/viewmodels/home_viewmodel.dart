// lib/viewmodels/home_viewmodel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/utils/plant_model.dart';

class HomeViewModel {
  // Estado
  PlantModel? _selectedModel;
  File? _image;
  List<double>? _predictions;
  bool _isLoading = false;

  // Getters
  PlantModel? get selectedModel => _selectedModel;
  File? get image => _image;
  List<double>? get predictions => _predictions;
  bool get isLoading => _isLoading;

  // Callback para notificar cambios a la UI
  final Function()? onStateChanged;

  HomeViewModel({this.onStateChanged});

  // 1. Seleccionar modelo
  void selectModel(PlantModel model) {
    _selectedModel = model;
    _resetAnalysis();
    _notifyListeners();
  }

  // 2. Seleccionar imagen
  Future<void> pickImage(ImageSource source) async {
    _notifyListeners();
  }

  // 3. Procesar imagen
  Future<void> processImage(Uint8List imageBytes) async {
    if (_selectedModel == null) return;

    _isLoading = true;
    _notifyListeners();

  }

  // 4. Reiniciar
  void reset() {
    _selectedModel = null;
    _resetAnalysis();
    _notifyListeners();
  }

  void _resetAnalysis() {
    _image = null;
    _predictions = null;
    _isLoading = false;
  }

  void _notifyListeners() {
    onStateChanged?.call();
  }
}