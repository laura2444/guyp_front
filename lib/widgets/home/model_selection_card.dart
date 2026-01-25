// lib/widgets/model_selection_card.dart
import 'package:flutter/material.dart';
import 'package:store_app/utils/plant_model.dart';

class ModelSelectionCard extends StatelessWidget {
  final String title;
  final PlantModel type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ModelSelectionCard({
    Key? key,
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            // Icono principal (similar a los estados del history)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),

            const SizedBox(width: 14),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Análisis de enfermedades',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Flecha discreta (como en listas del history)
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
