import 'package:flutter/material.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/widgets/weather_info_card.dart';
import 'package:store_app/models/weather_model.dart';

class AIAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> aiResponse;
  final String analysisId;

  const AIAnalysisScreen({
    Key? key,
    required this.aiResponse,
    required this.analysisId,
  }) : super(key: key);

  /// Parsea el objeto weather del mapa de respuesta (puede venir como Map desde el backend).
  WeatherModel? _parseWeather() {
    final w = aiResponse['weather'];
    if (w is Map) {
      return WeatherModel.fromJson(Map<String, dynamic>.from(w));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final aiData = aiResponse['ai_response'] ?? {};
    final mensaje = aiData['mensaje'] ?? 'No hay análisis disponible';
    final autocuidado = List<String>.from(aiData['autocuidado'] ?? []);
    final banderasRojas = List<String>.from(aiData['banderas_rojas'] ?? []);
    final cuandoBuscar = aiData['cuando_buscar_atencion'] ?? '';
    final descargo = aiData['descargo'] ?? '';
    final weather = _parseWeather();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(
        title: 'Análisis IA',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Clima del lugar del análisis
            if (weather != null) ...[
              WeatherInfoCard(weather: weather),
              const SizedBox(height: 20),
            ],

            // Diagnóstico principal
            _buildDiagnosisSection(mensaje),

            // Autocuidado
            if (autocuidado.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildCareSection(autocuidado),
            ],

            // Banderas rojas
            if (banderasRojas.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildWarningSection(banderasRojas),
            ],

            // Cuándo buscar atención
            if (cuandoBuscar.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildHelpSection(cuandoBuscar),
            ],

            // Descargo
            if (descargo.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDisclaimer(descargo),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análisis Completo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Generado por inteligencia artificial',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // DIAGNOSIS SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildDiagnosisSection(String mensaje) {
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  size: 22,
                  color: Colors.blue.shade700,
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
                    const SizedBox(height: 2),
                    Text(
                      'Evaluación principal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // CARE SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildCareSection(List<String> autocuidado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Recomendaciones de Cuidado',
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: autocuidado.asMap().entries.map((entry) {
              final index = entry.key;
              final tip = entry.value;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < autocuidado.length - 1 ? 14 : 0,
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
                        _cleanMarkdown(tip),
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
          ),
        ),
      ],
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
                        _cleanMarkdown(bandera),
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
  // DISCLAIMER
  // ════════════════════════════════════════════════════════════

  Widget _buildDisclaimer(String descargo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descargo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  String _cleanMarkdown(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }
}