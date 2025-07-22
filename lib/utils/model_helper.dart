import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelHelper {
  static late Interpreter _interpreter;
  static late List<int> _inputShape;
  static late List<int> _outputShape;

  static bool _initialized = false;

  /// Inicializa el modelo TFLite desde assets
  static Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/plant_disease_model.tflite',
        options: InterpreterOptions()..useNnApiForAndroid = true,
      );

      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      _initialized = true;

      print("✅ Modelo cargado exitosamente:");
      print("📥 Entrada: $_inputShape");
      print("📤 Salida: $_outputShape");
    } catch (e) {
      print("❌ Error al cargar el modelo: $e");
      _initialized = false;
    }
  }

  /// Clasifica una imagen y retorna la lista de probabilidades
  static List<double> classifyImage(Uint8List imageBytes) {
    if (!_initialized) {
      throw Exception("❌ El modelo no ha sido inicializado.");
    }

    final input = _preprocessImage(imageBytes);

    // Crear tensor de salida con la forma adecuada
    final output = List.filled(
      _outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape([_outputShape[0], _outputShape[1]]);

    _interpreter.run(input, output);

    return List<double>.from(output[0]); // Lista de probabilidades
  }

  /// Preprocesa la imagen para ajustarse al inputShape del modelo
  static List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception("❌ No se pudo decodificar la imagen.");
    }

    final height = _inputShape[1];
    final width = _inputShape[2];
    final channels = _inputShape[3];

    if (channels != 3) {
      throw Exception("❌ Solo se soportan imágenes RGB (3 canales).");
    }

    final resized = img.copyResize(decoded, width: width, height: height);

    return List.generate(1, (_) =>
        List.generate(height, (y) =>
          List.generate(width, (x) {
            final pixel = resized.getPixel(x, y);
            final r = (img.getRed(pixel) / 127.5) - 1.0;
            final g = (img.getGreen(pixel) / 127.5) - 1.0;
            final b = (img.getBlue(pixel) / 127.5) - 1.0;
            return [r, g, b];
          })
        )
    );
  }
}
