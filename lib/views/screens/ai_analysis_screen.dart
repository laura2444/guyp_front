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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Análisis con IA',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: $analysisId'),
            Text('Respuesta IA: ${aiResponse.toString()}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}