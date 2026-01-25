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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  image!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Resultado principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHealthy ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    size: 48,
                    color: isHealthy ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatPredictionName(prediction),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confianza: $confidence%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getConfidenceColor(confidence),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información del análisis
            Text(
              'Detalles del análisis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Cultivo', crop),
            const SizedBox(height: 12),
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),

            if (location != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Ubicación',
                '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}',
              ),
            ],

            const SizedBox(height: 32),

            // Botón para nuevo análisis
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Nuevo análisis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
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

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
}