import 'package:flutter/material.dart';
import 'package:store_app/widgets/custom_app_bar.dart';

class AIAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> aiResponse;
  final String analysisId;

  const AIAnalysisScreen({
    Key? key,
    required this.aiResponse,
    required this.analysisId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final aiData = aiResponse['ai_response'] ?? {};
    final mensaje = aiData['mensaje'] ?? 'No hay análisis disponible';
    final autocuidado = List<String>.from(aiData['autocuidado'] ?? []);
    final banderasRojas = List<String>.from(aiData['banderas_rojas'] ?? []);
    final cuandoBuscar = aiData['cuando_buscar_atencion'] ?? '';
    final descargo = aiData['descargo'] ?? '';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Análisis con IA',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 40, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Análisis Completo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Mensaje principal
            _buildSection(
              icon: Icons.info_outline,
              title: 'Diagnóstico',
              color: Colors.blue,
              child: Text(
                mensaje,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            // Autocuidado
            if (autocuidado.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildSection(
                icon: Icons.spa,
                title: 'Recomendaciones de Cuidado',
                color: Colors.green,
                child: Column(
                  children: autocuidado.map((tip) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 20,
                              color: Colors.green.shade600),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _cleanMarkdown(tip),
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Banderas rojas
            if (banderasRojas.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildSection(
                icon: Icons.warning_amber,
                title: 'Señales de Alerta',
                color: Colors.orange,
                child: Column(
                  children: banderasRojas.map((bandera) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flag,
                              size: 20,
                              color: Colors.orange.shade600),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _cleanMarkdown(bandera),
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Cuándo buscar atención
            if (cuandoBuscar.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildSection(
                icon: Icons.help_outline,
                title: 'Cuándo Buscar Ayuda',
                color: Colors.red,
                child: Text(
                  cuandoBuscar,
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],

            // Descargo
            if (descargo.isNotEmpty) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        descargo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24),

            // Botón volver
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
              style: ElevatedButton.styleFrom(
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _cleanMarkdown(String text) {
    // Elimina el formato markdown básico
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }
}