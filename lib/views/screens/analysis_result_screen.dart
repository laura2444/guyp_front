import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String analysisId;
  final String prediction;
  final String confidence;
  final String crop;
  final Position? location;
  final File? image;

  const AnalysisResultScreen({
    Key? key,
    required this.analysisId,
    required this.prediction,
    required this.confidence,
    required this.crop,
    this.location,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHealthy = prediction.toLowerCase().contains('healthy');

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Resultado del Análisis',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen arriba
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  image!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
            ],

            // Estado del resultado
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHealthy ? Colors.green.shade200 : Colors.orange.shade200,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    size: 60,
                    color: isHealthy ? Colors.green : Colors.orange,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _formatPredictionName(prediction),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Confianza: $confidence%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _getConfidenceColor(confidence),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Información básica
            _buildInfoRow('Cultivo', crop),
            Divider(height: 24),
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),

            if (location != null) ...[
              Divider(height: 24),
              _buildInfoRow(
                'Ubicación',
                '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}',
              ),
            ],

            SizedBox(height: 32),

            // Botón principal
            ElevatedButton.icon(
              onPressed: () => _generateAIAnalysis(context),
              icon: Icon(Icons.auto_awesome),
              label: Text('Generar Análisis con IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Botón secundario
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatPredictionName(String prediction) {
    return prediction
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  Color _getConfidenceColor(String confidence) {
    final value = double.tryParse(confidence) ?? 0.0;
    if (value >= 90) return Colors.green;
    if (value >= 70) return Colors.blue;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  void _generateAIAnalysis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generando análisis con IA...')),
    );
  }
}