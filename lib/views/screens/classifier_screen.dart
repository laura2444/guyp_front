// lib/views/screens/classifier_screen.dart
import 'dart:io';
import 'dart:math';
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
      userId: widget.userId,
      plantType: plantType,
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
      backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: _getTitle(),
          showBackButton: true,
          actions: [
            if (_viewModel.image != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FilledButton.icon(
                  onPressed: _showImagePicker,
                  icon: Icon(
                    Icons.switch_camera_rounded,
                    size: 16,
                  ),
                  label: Text('Cambiar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
      body: _buildBody(),
    );
  }

  String _getTitle() {
    return 'Análisis de ${_viewModel.plantDisplayName}';
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información de ubicación
            if (_viewModel.location != null) ...[
              _buildLocationCard(),
              SizedBox(height: 16),
            ],

            // Vista de imagen
            _buildImageSection(),
            SizedBox(height: 20),

            // Estados dinámicos
            if (_viewModel.isLoading || _viewModel.isUploading)
              _buildLoadingIndicator()
            else if (_viewModel.currentAnalysis != null)
              _buildResultsSection()
            else if (_viewModel.image != null)
                _buildReadyToProcessSection()
              else
                _buildWelcomeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final loc = _viewModel.location!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.green[700],
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación registrada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
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
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _viewModel.image == null ? _showImagePicker : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: _viewModel.image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _viewModel.image!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
                : _buildEmptyImagePlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_a_photo_rounded,
            size: 60,
            color: Colors.green[400],
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Toca para agregar imagen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Captura o selecciona una foto de tu planta',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 32),
          SizedBox(height: 12),
          Text(
            '¿Cómo funciona?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. Toca la imagen para seleccionar una foto\n2. Analiza con IA o modelo local\n3. Obtén resultados y recomendaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Icon(
                _viewModel.isUploading ? Icons.cloud_upload : Icons.auto_awesome,
                color: Colors.green,
                size: 28,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            _viewModel.isUploading ? 'Subiendo al servidor...' : 'Procesando imagen...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esto puede tomar unos segundos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToProcessSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.green[600],
          ),
          SizedBox(height: 16),
          Text(
            'Imagen cargada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Selecciona cómo deseas analizar tu planta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),

          // Botón principal - Análisis local
          ElevatedButton.icon(
            onPressed: _uploadToServer,
            icon: Icon(Icons.analytics_rounded, size: 20),
            label: Text('Análisis Local'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),

          SizedBox(height: 12),

          // Botón secundario - Análisis IA
          OutlinedButton.icon(
            onPressed: _generateWithAI,
            icon: Icon(Icons.auto_awesome_rounded, size: 20),
            label: Text('Análisis con IA'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple[600],
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: Colors.purple[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final analysis = _viewModel.currentAnalysis!;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green[600],
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Análisis completado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Resultado principal
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: analysis.isHealthy ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: analysis.isHealthy ? Colors.green[200]! : Colors.orange[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        analysis.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: analysis.isHealthy ? Colors.green[900] : Colors.orange[900],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(analysis.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: analysis.isHealthy ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: analysis.confidence,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      analysis.isHealthy ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Acciones
          if (_viewModel.analysisId == null && !_viewModel.isUploading) ...[
            ElevatedButton.icon(
              onPressed: _uploadToServer,
              icon: Icon(Icons.save_rounded, size: 20),
              label: Text('Guardar análisis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _generateWithAI,
              icon: Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text('Generar recomendaciones IA'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple[600],
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: Colors.purple[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else if (_viewModel.isUploading)
            Center(child: CircularProgressIndicator())
          else if (_viewModel.analysisId != null)
              _buildAnalysisSavedCard(analysis),
        ],
      ),
    );
  }

  Widget _buildAnalysisSavedCard(PlantAnalysisModel analysis) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis guardado exitosamente',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${analysis.id.substring(0, min(8, analysis.id.length))}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          if (!analysis.aiGenerated)
            IconButton(
              icon: Icon(Icons.auto_awesome, color: Colors.purple),
              onPressed: _generateWithAI,
              tooltip: 'Generar con IA',
            ),
        ],
      ),
    );
  }

  // ============ MÉTODOS DE LÓGICA ============

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _viewModel.image != null ? 'Cambiar imagen' : 'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Opción cámara
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.blue[600]),
                ),
                title: Text('Tomar foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Usa la cámara del dispositivo', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              Divider(height: 1, indent: 72),

              // Opción galería
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: Colors.purple[600]),
                ),
                title: Text('Elegir de galería', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Selecciona una imagen existente', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // Opción eliminar si hay imagen
              if (_viewModel.image != null) ...[
                Divider(height: 1, indent: 72),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red[600]),
                  ),
                  title: Text('Eliminar imagen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Quitar la imagen seleccionada', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    _viewModel.reset();
                  },
                ),
              ],

              SizedBox(height: 16),
            ],
          ),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error al cargar imagen'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _uploadToServer() async {
    if (_viewModel.location == null) {
      await _viewModel.getLocation();
    }

    final analysis = await _viewModel.uploadAnalysis();
    if (analysis != null) {
      _navigateToResultScreen(analysis);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error al guardar el análisis'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      _navigateToAIScreen(aiResult);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error generando análisis IA'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          prediction: analysis.prediction,
          confidence: '${(analysis.confidence * 100).toStringAsFixed(1)}',
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
            'weather': aiResult.weather?.toJson(),
            'message': 'Análisis generado con IA',
          },
          analysisId: aiResult.analysisId,
        ),
      ),
    );
  }
}