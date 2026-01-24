// lib/views/screens/classifier_screen.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/views/viewmodels/classifier_viewmodel.dart';

import '../../models/plant_analysis_model.dart';
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

    // Convertir PlantModel a string para el ViewModel
    String plantType = '';
    switch (widget.selectedModel) {
      case PlantModel.tomato:
        plantType = 'tomato';
        break;
      case PlantModel.pepper:
        plantType = 'pepper';
        break;
      case PlantModel.potato:
        plantType = 'potato';
        break;
    }

    _viewModel = ClassifierViewModel(
      userId: widget.userId,           // Parámetro requerido
      plantType: plantType,            // Convertido de PlantModel
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
    // Usar el display name del ViewModel
    return 'Análisis de ${_viewModel.plantDisplayName}';
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

          // 3. Estado de procesamiento
          if (_viewModel.isLoading || _viewModel.isUploading)
            _buildLoadingIndicator()
          else if (_viewModel.currentAnalysis != null)
            _buildResultsSection()
          else if (_viewModel.image != null)
              _buildReadyToProcessSection(),
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
          _viewModel.isUploading ? 'Subiendo al servidor...' : 'Procesando...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReadyToProcessSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '📷 Imagen lista',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Presiona el botón para analizar la imagen',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadToServer,
              icon: Icon(Icons.cloud_upload, size: 20),
              label: Text('Analizar imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _generateWithAI,
              icon: Icon(Icons.auto_awesome, size: 20),
              label: Text('Analizar con IA'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    final analysis = _viewModel.currentAnalysis!;

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
                    color: analysis.isHealthy ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: analysis.isHealthy ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    analysis.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: analysis.isHealthy ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '${(analysis.confidence * 100).toStringAsFixed(1)}% confianza',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Botones de acción
            if (_viewModel.analysisId == null && !_viewModel.isUploading)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploadToServer,
                    icon: Icon(Icons.save, size: 20),
                    label: Text('Guardar análisis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _generateWithAI,
                    icon: Icon(Icons.auto_awesome, size: 20),
                    label: Text('Generar con IA'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              )
            else if (_viewModel.isUploading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (_viewModel.analysisId != null)
                _buildAnalysisSavedCard(analysis),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSavedCard(PlantAnalysisModel analysis) {
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
                  'ID: ${analysis.id.substring(0, min(8, analysis.id.length))}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          if (analysis.aiGenerated)
            Icon(Icons.auto_awesome, color: Colors.purple)
          else
            TextButton(
              onPressed: _generateWithAI,
              child: Text('+ IA'),
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

    final analysis = await _viewModel.uploadAnalysis();
    if (analysis != null) {
      // Navegar a pantalla de resultados
      _navigateToResultScreen(analysis);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar el análisis'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateWithAI() async {
    if (_viewModel.location == null) {
      await _viewModel.getLocation();
    }

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

  void _navigateToResultScreen(PlantAnalysisModel analysis) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(
          analysisId: analysis.id,
          prediction: analysis.prediction ?? 'Desconocido',
          confidence: analysis.confidence != null
              ? '${(analysis.confidence! * 100).toStringAsFixed(1)}'
              : '0.0',
          crop: analysis.plantDisplayName,
          location: _viewModel.location,
          image: _viewModel.image,
        ),
      ),
    );
  }

  void _navigateToAIScreen(AIAnalysisResponse aiResult) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIAnalysisScreen(
          aiResponse: {
            'analysis_id': aiResult.analysisId,
            'plant_type': aiResult.plantType,
            'prediction': aiResult.prediction,
            'confidence': aiResult.confidence,
            'ai_generated': aiResult.aiGenerated,
            'ai_response': aiResult.aiResponse,
            'message': 'Análisis generado con IA',
          },
          analysisId: aiResult.analysisId,
        ),
      ),
    );
  }
}