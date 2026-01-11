import 'dart:typed_data';
import 'package:store_app/utils/plant_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelHelper {
  /** Se implementó un gestor de modelos TFLite con carga diferida (lazy loading), permitiendo inicializar
   * únicamente el modelo requerido en tiempo de ejecución, optimizando el uso de memoria y reduciendo
   * el tiempo de arranque de la aplicación. */

  static final Map<PlantModel, Interpreter> _interpreters = {};
  static final Map<PlantModel, List<int>> _inputShapes = {};
  static final Map<PlantModel, List<int>> _outputShapes = {};

  static const Map<PlantModel, String> _modelPaths = {
    PlantModel.tomato: 'assets/models/plant_disease_model.tflite',
    PlantModel.pepper: 'assets/models/plant_disease_model.tflite',
    PlantModel.potato: 'assets/models/plant_disease_model.tflite',
  };

  /// Carga el modelo solo si aún no está cargado
  static Future<void> _loadModelIfNeeded(PlantModel model) async {
    if (_interpreters.containsKey(model)) return;

    final interpreter = await Interpreter.fromAsset(
      _modelPaths[model]!,
      options: InterpreterOptions()..useNnApiForAndroid = true,
    );

    _interpreters[model] = interpreter;
    _inputShapes[model] = interpreter.getInputTensor(0).shape;
    _outputShapes[model] = interpreter.getOutputTensor(0).shape;

    print("✅ Modelo $model cargado:");
    print("📥 ${_inputShapes[model]}");
    print("📤 ${_outputShapes[model]}");
  }

  /// Clasifica usando el modelo solicitado
  static Future<List<double>> classifyImage({
    required PlantModel model,
    required Uint8List imageBytes,
  }) async {
    await _loadModelIfNeeded(model);

    final interpreter = _interpreters[model]!;
    final inputShape = _inputShapes[model]!;
    final outputShape = _outputShapes[model]!;

    final input = _preprocessImage(imageBytes, inputShape);

    final output = List.filled(
      outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape([outputShape[0], outputShape[1]]);

    interpreter.run(input, output);

    return List<double>.from(output[0]);
  }

  /// Preprocesamiento genérico según el shape del modelo
  static List<List<List<List<double>>>> _preprocessImage(
      Uint8List imageBytes, List<int> inputShape) {

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception("No se pudo decodificar la imagen");
    }

    final height = inputShape[1];
    final width = inputShape[2];
    final channels = inputShape[3];

    if (channels != 3) {
      throw Exception("Solo se soporta RGB");
    }

    final resized = img.copyResize(decoded, width: width, height: height);

    return [
      List.generate(height, (y) =>
          List.generate(width, (x) {
            final p = resized.getPixel(x, y);
            final r = (img.getRed(p) / 127.5) - 1.0;
            final g = (img.getGreen(p) / 127.5) - 1.0;
            final b = (img.getBlue(p) / 127.5) - 1.0;
            return [r, g, b];
          })
      )
    ];
  }

  /// Libera un modelo si ya no se usa
  static void disposeModel(PlantModel model) {
    if (_interpreters.containsKey(model)) {
      _interpreters[model]!.close();
      _interpreters.remove(model);
      _inputShapes.remove(model);
      _outputShapes.remove(model);
      print("🧹 Modelo $model liberado");
    }
  }

}
