// lib/views/screens/classifier_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/views/viewmodels/classifier_viewmodel.dart';

import 'ai_analysis_screen.dart';
import 'analysis_result_screen.dart';

class ClassifierScreen extends StatefulWidget {
  final PlantModel selectedModel;
  final String userId;

  const ClassifierScreen({
    Key? key,
    required this.selectedModel,
    required this.userId,
  }) : super(key: key);

  @override
  _ClassifierScreenState createState() => _ClassifierScreenState();
}

class _ClassifierScreenState extends State<ClassifierScreen> {
  late ClassifierViewModel _viewModel;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = ClassifierViewModel(
      selectedModel: widget.selectedModel,
      userId: widget.userId,
      onStateChanged: () => setState(() {}),
    );
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _viewModel.getLocation();
    print('📍 Ubicación obtenida: ${_viewModel.location}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        showBackButton: true,
        actions: [
          if (_viewModel.image != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _viewModel.reset,
              tooltip: 'Nueva imagen',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  String _getTitle() {
    switch (widget.selectedModel) {
      case PlantModel.tomato: return 'Análisis de Tomate';
      case PlantModel.pepper: return 'Análisis de Pimiento';
      case PlantModel.potato: return 'Análisis de Papa';
    }
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Información de ubicación
          if (_viewModel.location != null)
            _buildLocationCard(),

          SizedBox(height: 16),

          // 2. Vista de imagen
          Expanded(
            child: _buildImageSection(),
          ),

          SizedBox(height: 20),

          // 3. Resultados o estado
          if (_viewModel.isLoading)
            _buildLoadingIndicator()
          else if (_viewModel.predictions != null)
            _buildResultsSection(),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final loc = _viewModel.location!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[100]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green[600], size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación registrada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _showImagePicker,
        borderRadius: BorderRadius.circular(16),
        child: _viewModel.image != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _viewModel.image!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 60,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Toque para seleccionar imagen',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                'o use los botones de abajo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text(
          'Procesando imagen...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    final predictions = _viewModel.predictions!;
    final labels = ['Bacterial', 'Fungal', 'Healthy', 'Leaf Spots', 'Viral'];
    final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
    final predictedLabel = labels[maxIndex];
    final confidence = (predictions[maxIndex] * 100).toStringAsFixed(1);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Resultado del análisis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorForLabel(predictedLabel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getColorForLabel(predictedLabel).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    predictedLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getColorForLabel(predictedLabel),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '$confidence% de confianza',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Botón para subir al servidor
            if (_viewModel.analysisId == null && !_viewModel.isUploading)
              ElevatedButton.icon(
                onPressed: _uploadToServer,
                icon: Icon(Icons.cloud_upload, size: 20),
                label: Text('Guardar análisis en servidor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else if (_viewModel.isUploading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (_viewModel.analysisId != null)
                _buildAnalysisSavedCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSavedCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Análisis guardado',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'ID: ${_viewModel.analysisId!.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _generateAI,
            child: Text('Generar IA'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'camera',
          onPressed: () => _pickImage(ImageSource.camera),
          child: Icon(Icons.camera_alt),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'gallery',
          onPressed: () => _pickImage(ImageSource.gallery),
          child: Icon(Icons.photo_library),
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  // ============ MÉTODOS DE LÓGICA ============

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.purple),
              title: Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (picked != null) {
        final imageFile = File(picked.path);
        _viewModel.setImage(imageFile);

        // Procesar la imagen
        final bytes = await imageFile.readAsBytes();
        await _viewModel.processImage(Uint8List.fromList(bytes));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  Future<void> _uploadToServer() async {
    if (_viewModel.location == null) {
      await _viewModel.getLocation();
    }

    final analysisId = await _viewModel.uploadAnalysis();
    if (analysisId != null) {
      // Navegar a pantalla de resultados
      _navigateToResultScreen(analysisId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar el análisis'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _generateAI() async {
    final aiResult = await _viewModel.generateWithAI();
    if (aiResult != null) {
      // Navegar a pantalla de IA
      _navigateToAIScreen(aiResult);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error generando IA'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToResultScreen(String analysisId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(
          analysisId: analysisId,
          prediction: _getPredictionLabel(),
          confidence: _getConfidence(),
          crop: _getCropName(),
          location: _viewModel.location,
          image: _viewModel.image,
        ),
      ),
    );
  }

  void _navigateToAIScreen(Map<String, dynamic> aiResult) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIAnalysisScreen(
          aiResponse: aiResult,
          analysisId: _viewModel.analysisId ?? '',
        ),
      ),
    );
  }

// Métodos auxiliares
  String _getPredictionLabel() {
    final labels = ['Bacterial', 'Fungal', 'Healthy', 'Leaf Spots', 'Viral'];
    final predictions = _viewModel.predictions!;
    final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
    return labels[maxIndex];
  }

  String _getConfidence() {
    final predictions = _viewModel.predictions!;
    final maxValue = predictions.reduce((a, b) => a > b ? a : b);
    return (maxValue * 100).toStringAsFixed(1);
  }

  String _getCropName() {
    switch (_viewModel.selectedModel) {
      case PlantModel.tomato: return 'Tomate';
      case PlantModel.pepper: return 'Pimiento';
      case PlantModel.potato: return 'Papa';
    }
  }

  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'healthy': return Colors.green;
      case 'bacterial': return Colors.red;
      case 'fungal': return Colors.orange;
      case 'viral': return Colors.purple;
      case 'leaf spots': return Colors.amber;
      default: return Colors.blue;
    }
  }
}