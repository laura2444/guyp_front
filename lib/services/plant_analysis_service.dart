import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:store_app/models/plant_analysis_model.dart';
import 'package:store_app/global_variables.dart';

// ============ ANÁLISIS BÁSICO ============

Future<Map<String, dynamic>> uploadAnalysis({
  required String plantType,  // 'tomato', 'potato', 'pepper' - NUEVO
  required String userId,
  required double lat,
  required double lng,
  required File imageFile,
}) async {
  try {
    final url = Uri.parse('$uri/analysis/$plantType');  // CAMBIADO
    final request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = userId
    // ..fields['prediction'] = prediction  // ELIMINADO (lo calcula la API)
      ..fields['lat'] = lat.toString()
      ..fields['lng'] = lng.toString()
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return jsonDecode(responseBody.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${responseBody.body}');
    }
  } catch (e) {
    print('Error uploadAnalysis: $e');
    rethrow;
  }
}

// ============ ANÁLISIS CON IA ============

Future<Map<String, dynamic>> uploadAnalysisWithAI({
  required String plantType,  // NUEVO
  required String userId,
  required double lat,
  required double lng,
  required File imageFile,
}) async {
  try {
    final url = Uri.parse('$uri/analysis/$plantType/with-ai');  // CAMBIADO
    final request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = userId
      ..fields['lat'] = lat.toString()
      ..fields['lng'] = lng.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: 'analysis_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return jsonDecode(responseBody.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${responseBody.body}');
    }
  } catch (e) {
    print('Error uploadAnalysisWithAI: $e');
    rethrow;
  }
}

// ============ CRUD ============

Future<List<PlantAnalysisModel>> getUserAnalyses(String userId) async {
  try {
    final url = Uri.parse('$uri/user/$userId/analysis');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Manejar diferentes formatos de respuesta
      if (data is List) {
        return data.map((e) => PlantAnalysisModel.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('message')) {
        // No hay análisis para este usuario
        return [];
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getUserAnalyses: $e');
    rethrow;
  }
}

Future<PlantAnalysisModel> getAnalysis(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PlantAnalysisModel.fromJson(data);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getAnalysis: $e');
    rethrow;
  }
}

Future<List<PlantAnalysisModel>> getAllAnalyses() async {
  try {
    final url = Uri.parse('$uri/analysis/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PlantAnalysisModel.fromJson(e)).toList();
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getAllAnalyses: $e');
    rethrow;
  }
}

Future<bool> deleteAnalysis(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error deleteAnalysis: $e');
    rethrow;
  }
}

// ============ ENDPOINTS AI ============

Future<Map<String, dynamic>> getAnalysisAIResponse(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getAnalysisAIResponse: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> getAnalysisAISummary(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai/summary');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getAnalysisAISummary: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> getAnalysisAIStatus(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai/status');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('Error getAnalysisAIStatus: $e');
    rethrow;
  }
}

// ============ UTILIDADES ============

// Obtener plantas disponibles
Future<Map<String, dynamic>> getAvailablePlants() async {
  try {
    final url = Uri.parse('$uri/plants');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Valores por defecto
      return {
        'available_plants': ['tomato', 'potato', 'pepper'],
        'diseases_per_plant': {
          'tomato': [
            'Bacterial_spot', 'Early_blight', 'Late_blight', 'Leaf_Mold',
            'Septoria_leaf_spot', 'Tomato_Yellow_Leaf_Curl_Virus',
            'Tomato_mosaic_virus', 'Healthy'
          ],
          'potato': ['Early_blight', 'Late_blight', 'Healthy'],
          'pepper': ['Bacterial_spot', 'Healthy'],
        }
      };
    }
  } catch (e) {
    print('Error getAvailablePlants: $e');
    rethrow;
  }
}

// URL de imágenes (ajustar según tu API)
String getImageUrl(String imageId) {
  return '$uri/images/$imageId';  // Esto depende de cómo sirvas las imágenes
}

// Validar ObjectId
bool isValidObjectId(String id) {
  return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
}

// Conversión de nombre de planta
String normalizePlantType(String plantType) {
  switch (plantType.toLowerCase()) {
    case 'tomato':
      return 'tomato';
    case 'potato':
    case 'papa':
      return 'potato';
    case 'pepper':
    case 'pimienta':
    case 'bell pepper':
      return 'pepper';
    default:
      return 'tomato'; // default
  }
}