// lib/views/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/widgets/home/model_selection_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Clasificador de Plantas',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: _buildModelSelection(),
    );
  }

  Widget _buildModelSelection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mejorado
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👋 ¡Hola!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selecciona el cultivo que deseas analizar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Tarjetas de selección
          Expanded(
            child: ListView(
              children: [
                ModelSelectionCard(
                  title: 'Tomate',
                  type: PlantModel.tomato,
                  icon: Icons.spa,
                  color: Colors.red[400]!,
                  onTap: () => _navigateToClassifier(PlantModel.tomato),
                ),
                SizedBox(height: 16),

                ModelSelectionCard(
                  title: 'Pimiento',
                  type: PlantModel.pepper,
                  icon: Icons.local_florist,
                  color: Colors.green[500]!,
                  onTap: () => _navigateToClassifier(PlantModel.pepper),
                ),
                SizedBox(height: 16),

                ModelSelectionCard(
                  title: 'Papa',
                  type: PlantModel.potato,
                  icon: Icons.grass,
                  color: Colors.orange[500]!,
                  onTap: () => _navigateToClassifier(PlantModel.potato),
                ),

                // Espacio adicional
                SizedBox(height: 40),

                // Información adicional
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.green[600], size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Todos los modelos usan IA entrenada específicamente para cada cultivo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToClassifier(PlantModel model) {
    print('Navegando a clasificador de: $model');
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información'),
        content: Text('Esta app utiliza modelos de IA para detectar enfermedades en plantas agrícolas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }
}