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
//NOSE ESTA USANDO
String getImageUrl(String imageId) {
  return '$uri/images/$imageId';
}
