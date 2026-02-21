import 'package:flutter/material.dart';
import 'package:store_app/global_variables.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/widgets/weather_info_card.dart';

import '../../models/plant_analysis_model.dart';

class AnalysisAIDetailScreen extends StatelessWidget {
  final PlantAnalysisModel analysis;

  const AnalysisAIDetailScreen({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final aiSummary = analysis.aiSummary ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(
        title: 'Análisis IA',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            _buildImage(),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlantHeader(),
                  const SizedBox(height: 20),
                  if (analysis.weather != null) ...[
                    WeatherInfoCard(weather: analysis.weather!),
                    const SizedBox(height: 20),
                  ],
                  _buildDiagnosis(),
                  const SizedBox(height: 24),
                  _buildAISummary(aiSummary),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // IMAGE
  // ════════════════════════════════════════════════════════════

  Widget _buildImage() {
    final imageId = analysis.imageId;

    if (imageId.isEmpty) {
      return _buildImagePlaceholder(
        Icons.image_not_supported_outlined,
        'Sin imagen',
      );
    }

    final imageUrl = '$uri/images/$imageId';

    return Hero(
      tag: 'plant_image_${analysis.imageId}',
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return _buildImagePlaceholder(
              Icons.broken_image_outlined,
              'Error al cargar',
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon, String text) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // PLANT HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildPlantHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          analysis.plantDisplayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Colors.purple[700],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Analizado con IA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // DIAGNOSIS
  // ════════════════════════════════════════════════════════════

  Widget _buildDiagnosis() {
    final isHealthy = analysis.isHealthy;
    final confidencePercent = (analysis.confidence * 100).round();
    final color = isHealthy ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                  size: 22,
                  color: color.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIAGNÓSTICO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConfidenceBar(confidencePercent, color),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(int confidencePercent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nivel de confianza',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$confidencePercent%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: analysis.confidence,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // AI SUMMARY
  // ════════════════════════════════════════════════════════════

  Widget _buildAISummary(Map<String, dynamic> aiSummary) {
    if (aiSummary.isEmpty) {
      return _buildEmptyAI();
    }

    // Extraer campos específicos si existen
    final banderasRojas = _extractList(aiSummary, ['banderas_rojas', 'red_flags', 'warning_signs']);
    final cuandoBuscar = _extractString(aiSummary, ['cuando_buscar_atencion', 'when_to_seek_help', 'seek_attention']);

    // Filtrar estos campos del summary general
    final filteredSummary = Map<String, dynamic>.from(aiSummary)
      ..removeWhere((key, value) =>
      key == 'banderas_rojas' ||
          key == 'red_flags' ||
          key == 'warning_signs' ||
          key == 'cuando_buscar_atencion' ||
          key == 'when_to_seek_help' ||
          key == 'seek_attention'
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recomendaciones generales
        if (filteredSummary.isNotEmpty) ...[
          Text(
            'Recomendaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...filteredSummary.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSummarySection(entry.key, entry.value),
            );
          }).toList(),
        ],

        // Señales de alerta
        if (banderasRojas.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildWarningSection(banderasRojas),
          const SizedBox(height: 16),
        ],

        // Cuándo buscar ayuda
        if (cuandoBuscar.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildHelpSection(cuandoBuscar),
        ],
      ],
    );
  }

  Widget _buildEmptyAI() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 36,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Sin recomendaciones disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String key, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatTitle(key),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          _buildSummaryContent(value),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(dynamic value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < value.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Text(
      value.toString(),
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Colors.grey[700],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // WARNING SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildWarningSection(List<String> banderasRojas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Señales de Alerta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: banderasRojas.asMap().entries.map((entry) {
              final index = entry.key;
              final bandera = entry.value;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < banderasRojas.length - 1 ? 14 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 18,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bandera,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELP SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildHelpSection(String cuandoBuscar) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 20,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cuándo Buscar Ayuda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cuandoBuscar,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.red.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  List<String> _extractList(Map<String, dynamic> summary, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (summary.containsKey(key)) {
        final value = summary[key];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
      }
    }
    return [];
  }

  String _extractString(Map<String, dynamic> summary, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (summary.containsKey(key)) {
        final value = summary[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return '';
  }

  String _formatTitle(String key) {
    // Convert snake_case or camelCase to Title Case
    return key
        .replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
    )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word.isEmpty
        ? ''
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}