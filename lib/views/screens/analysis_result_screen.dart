import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:store_app/widgets/custom_app_bar.dart';

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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Resultado del Análisis',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: $analysisId'),
            Text('Predicción: $prediction'),
            Text('Confianza: $confidence%'),
            Text('Cultivo: $crop'),
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