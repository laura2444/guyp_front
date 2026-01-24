import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/models/plant_analysis_model.dart';

class AnalysisCard extends StatelessWidget {
  final PlantAnalysisModel analysis;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AnalysisCard({
    Key? key,
    required this.analysis,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black54;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    // Valores seguros
    final confidence = analysis.confidence ?? 0.0;
    final location = analysis.location;
    final lat = location?['lat'] ?? 0.0;
    final lng = location?['lng'] ?? 0.0;
    final hasLocation = lat != 0.0 || lng != 0.0;
    final plantType = analysis.plantType ?? 'tomato';

    // Color según si es saludable o no
    final isHealthy = analysis.prediction?.toLowerCase().contains('healthy') ?? false;
    final healthColor = isHealthy ? Colors.green : Colors.orange;

    // Icono según tipo de planta
    final plantIcon = _getPlantIcon(plantType);

    // Nombre amigable de planta
    final plantDisplayName = plantType == 'tomato' ? 'Tomate' :
    plantType == 'potato' ? 'Papa' :
    plantType == 'pepper' ? 'Pimiento' : 'Planta';

    // Nombre formateado de la enfermedad
    final displayName = analysis.prediction?.replaceAll('_', ' ').split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ') ?? 'Desconocido';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: healthColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con tipo de planta y estado
              Row(
                children: [
                  Icon(plantIcon, color: healthColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    plantDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  // Indicador de salud
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: healthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: healthColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      isHealthy ? 'SANA' : 'ENFERMA',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: healthColor,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Predicción y confianza
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Barra de confianza
                  Container(
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(confidence * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        LinearProgressIndicator(
                          value: confidence,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Información adicional
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Fecha
                  if (analysis.createdAt != null)
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      text: '${analysis.createdAt!.day}/'
                          '${analysis.createdAt!.month}/'
                          '${analysis.createdAt!.year}',
                    ),
                  // Hora
                  if (analysis.createdAt != null)
                    _buildInfoChip(
                      icon: Icons.access_time,
                      text: '${analysis.createdAt!.hour}:'
                          '${analysis.createdAt!.minute.toString().padLeft(2, '0')}',
                    ),
                  // Ubicación
                  if (hasLocation)
                    _buildInfoChip(
                      icon: Icons.location_on,
                      text: '${lat.toStringAsFixed(4)}, '
                          '${lng.toStringAsFixed(4)}',
                    ),
                  // ID de clase
                  if (analysis.classId != null)
                    _buildInfoChip(
                      icon: Icons.tag,
                      text: 'Clase ${analysis.classId}',
                    ),
                  // IA generada
                  if (analysis.aiGenerated == true)
                    _buildInfoChip(
                      icon: Icons.auto_awesome,
                      text: 'Con IA',
                      color: Colors.purple,
                    ),
                ],
              ),

              // Resumen AI (si existe)
              if (analysis.aiSummary != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                          const SizedBox(width: 6),
                          Text(
                            'Resumen IA',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis.aiSummary?['diagnóstico']?.toString() ??
                            analysis.aiSummary?['summary']?.toString() ??
                            analysis.aiSummary?['analisis']?.toString() ??
                            'Análisis generado por IA',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color color = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlantIcon(String plantType) {
    switch (plantType.toLowerCase()) {
      case 'tomato':
        return Icons.grass;
      case 'potato':
        return Icons.eco;
      case 'pepper':
        return Icons.local_fire_department;
      default:
        return Icons.psychology;
    }
  }
}