import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:store_app/models/plant_analysis_model.dart';
import 'package:store_app/global_variables.dart';

Future<bool> uploadAnalysis({
  required String userId,
  required String prediction,
  required double lat,
  required double lng,
  required File imageFile,
}) async {
  final url = Uri.parse('$uri/analysis/');
  final request = http.MultipartRequest('POST', url)
    ..fields['user_id'] = userId
    ..fields['prediction'] = prediction
    ..fields['lat'] = lat.toString()
    ..fields['lng'] = lng.toString()
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  final response = await request.send();
  return response.statusCode == 200;
}

Future<List<PlantAnalysisModel>> getUserAnalyses(String userId) async {
  final url = Uri.parse('$uri/user/$userId/analysis');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => PlantAnalysisModel.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar análisis');
  }
}

Future<bool> deleteAnalysis(String analysisId) async {
  final url = Uri.parse('$uri/analysis/$analysisId');
  final response = await http.delete(url);
  return response.statusCode == 200;
}
String getImageUrl(String imageId) {
  return '$uri/images/$imageId';
}

// ============ NUEVOS MÉTODOS ============

// 1. Subir análisis con IA (POST /analysis/with-ai)
Future<Map<String, dynamic>?> uploadAnalysisWithAI({
  required String userId,
  required String prediction,
  required double lat,
  required double lng,
  required File imageFile,
}) async {
  try {
    final url = Uri.parse('$uri/analysis/with-ai');
    final request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = userId
      ..fields['prediction'] = prediction
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
    }
    return null;
  } catch (e) {
    print('Error uploadAnalysisWithAI: $e');
    return null;
  }
}

// 2. Obtener respuesta completa de IA (GET /analysis/{id}/ai)
Future<Map<String, dynamic>?> getAnalysisAIResponse(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  } catch (e) {
    print('Error getAnalysisAIResponse: $e');
    return null;
  }
}

// 3. Obtener solo el resumen de IA (GET /analysis/{id}/ai/summary)
Future<Map<String, dynamic>?> getAnalysisAISummary(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai/summary');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  } catch (e) {
    print('Error getAnalysisAISummary: $e');
    return null;
  }
}

// 4. Verificar estado de IA (GET /analysis/{id}/ai/status)
Future<Map<String, dynamic>?> getAnalysisAIStatus(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId/ai/status');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  } catch (e) {
    print('Error getAnalysisAIStatus: $e');
    return null;
  }
}

// 5. Obtener análisis específico (GET /analysis/{id})
Future<PlantAnalysisModel?> getAnalysis(String analysisId) async {
  try {
    final url = Uri.parse('$uri/analysis/$analysisId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PlantAnalysisModel.fromJson(data);
    }
    return null;
  } catch (e) {
    print('Error getAnalysis: $e');
    return null;
  }
}

// 6. Obtener todos los análisis (GET /analysis/)
Future<List<PlantAnalysisModel>> getAllAnalyses() async {
  try {
    final url = Uri.parse('$uri/analysis/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PlantAnalysisModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('Error getAllAnalyses: $e');
    return [];
  }
}