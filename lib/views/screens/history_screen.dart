// lib/views/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/views/viewmodels/history_viewmodel.dart';
import 'package:store_app/widgets/analysis_card.dart';
import 'package:store_app/widgets/custom_app_bar.dart';

import '../../models/plant_analysis_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel()..loadAnalyses(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: 'Historial de Análisis',
          showBackButton: false,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        // Estado de carga inicial
        if (viewModel.isLoading && viewModel.analyses.isEmpty) {
          return _buildLoadingView();
        }

        // Estado de error
        if (viewModel.hasError) {
          return _buildErrorView(context, viewModel);
        }

        // Estado vacío
        if (viewModel.isEmpty) {
          return _buildEmptyView();
        }

        // Estado con datos
        return _buildListView(context, viewModel);
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Cargando análisis...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, HistoryViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 28),
            Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                viewModel.error ?? 'No se pudieron cargar los análisis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 36),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => viewModel.refresh(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_rounded,
                size: 80,
                color: Colors.green[400],
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Sin análisis todavía',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Comienza a analizar tus plantas y todo tu historial aparecerá aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_camera_rounded, color: Colors.green[600], size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Usa la cámara para empezar',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, HistoryViewModel viewModel) {
    final analyses = viewModel.recentAnalyses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con contador
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                'Análisis recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${analyses.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de análisis
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            color: Colors.green[600],
            backgroundColor: Colors.white,
            child: analyses.isEmpty
                ? _buildEmptyScrollView()
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
              physics: BouncingScrollPhysics(),
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final analysis = analyses[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: AnalysisCard(
                    analysis: analysis,
                    onDelete: () => _showDeleteDialog(context, viewModel, analysis),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyScrollView() {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 400,
          child: Center(
            child: Text(
              'No hay análisis',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      HistoryViewModel viewModel,
      PlantAnalysisModel analysis,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[600],
                  size: 40,
                ),
              ),
              SizedBox(height: 20),

              // Título
              Text(
                'Eliminar análisis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),

              // Descripción
              Text(
                '¿Estás seguro de que deseas eliminar este análisis? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Botón Eliminar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final success = await viewModel.deleteAnalysis(analysis.id);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    success ? 'Análisis eliminado correctamente' : 'Error al eliminar el análisis',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: success ? Colors.green[600] : Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.all(16),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}