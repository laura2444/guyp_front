import 'package:flutter/material.dart';
import '../global_variables.dart';
import '../models/plant_analysis_model.dart';
import '../views/screens/analysis_ai_detail_screen.dart';

class AnalysisCard extends StatelessWidget {
  final PlantAnalysisModel analysis;
  final VoidCallback onDelete;

  const AnalysisCard({
    super.key,
    required this.analysis,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = analysis.isHealthy;
    final confidencePercent = (analysis.confidence * 100).round();
    final hasAIAnalysis = analysis.aiGenerated && analysis.aiResponse != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasAIAnalysis
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnalysisAIDetailScreen(analysis: analysis),
            ),
          );
        }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== IMAGE ====================
            _buildImageHeader(context, isHealthy),

            // ==================== CONTENT ====================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name and date
                  _buildPlantInfo(),

                  const SizedBox(height: 16),

                  // Diagnosis
                  _buildDiagnosis(isHealthy),

                  const SizedBox(height: 12),

                  // Confidence
                  _buildConfidence(confidencePercent),

                  // AI Button
                  if (hasAIAnalysis) ...[
                    const SizedBox(height: 16),
                    _buildAIButton(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // IMAGE HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildImageHeader(BuildContext context, bool isHealthy) {
    return Stack(
      children: [
        // Image
        _buildImage(),

        // Status badge (top-left)
        Positioned(
          top: 12,
          left: 12,
          child: _buildStatusBadge(isHealthy),
        ),

        // Menu button (top-right)
        Positioned(
          top: 8,
          right: 8,
          child: _buildMenuButton(context),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final imageId = analysis.imageId;

    if (imageId == null || imageId.isEmpty) {
      return _buildImagePlaceholder();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        '$uri/images/$imageId',
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.grey[400],
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(
        Icons.eco_outlined,
        size: 48,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildStatusBadge(bool isHealthy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isHealthy ? 'Saludable' : 'Atención',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeleteDialog(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // CONTENT SECTIONS
  // ════════════════════════════════════════════════════════════

  Widget _buildPlantInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analysis.plantDisplayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(analysis.createdAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosis(bool isHealthy) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isHealthy ? Icons.spa_rounded : Icons.healing_rounded,
            size: 20,
            color: isHealthy ? Colors.green[700] : Colors.orange[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnóstico',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                analysis.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isHealthy ? Colors.green[800] : Colors.orange[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidence(int confidencePercent) {
    final color = _getConfidenceColor(confidencePercent);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confianza',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$confidencePercent%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: analysis.confidence,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.shade100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: Colors.purple[700],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ver análisis de IA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple[800],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.purple[600],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DIALOGS & HELPERS
  // ════════════════════════════════════════════════════════════

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Eliminar análisis',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este análisis?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getConfidenceColor(int percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 60) return Colors.blue;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }
}