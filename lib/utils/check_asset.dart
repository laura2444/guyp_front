import 'package:flutter/services.dart';

void main() async {
  try {
    await rootBundle.load('assets/models/plant_disease_model.tflite');
    print('✅ El archivo existe y es accesible');
  } catch (e) {
    print('❌ Error: $e');
  }
}