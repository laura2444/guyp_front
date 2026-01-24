import 'dart:convert';

class PlantAnalysisModel {
  final String id;
  final String userId;
  final String plantType;          // 'tomato', 'potato', 'pepper' - NUEVO
  final String prediction;         // Nombre de enfermedad
  final int? classId;              // ID numérico de la clase - NUEVO
  final double confidence;         // 0.0 - 1.0 - NUEVO
  final Map<String, double> location;
  final String imageId;            // Cambiado de imageUrl a imageId
  final Map<String, dynamic>? aiResponse;  // Respuesta de Gemini - NUEVO
  final Map<String, dynamic>? aiSummary;   // Resumen de Gemini - NUEVO
  final bool aiGenerated;          // Si tiene contenido AI - NUEVO
  final DateTime createdAt;

  PlantAnalysisModel({
    required this.id,
    required this.userId,
    required this.plantType,
    required this.prediction,
    this.classId,
    required this.confidence,
    required this.location,
    required this.imageId,
    this.aiResponse,
    this.aiSummary,
    this.aiGenerated = false,
    required this.createdAt,
  });

  factory PlantAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PlantAnalysisModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      plantType: json['plant_type']?.toString() ?? 'tomato',
      prediction: json['prediction']?.toString() ?? 'Desconocido',
      classId: (json['class_id'] ?? json['classId'])?.toInt(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      location: _parseLocation(json['location']),
      imageId: json['image_url']?.toString() ??
          json['image_id']?.toString() ??
          json['imageId']?.toString() ?? '',
      aiResponse: json['ai_response'] is Map ? Map<String, dynamic>.from(json['ai_response']) : null,
      aiSummary: json['ai_summary'] is Map ? Map<String, dynamic>.from(json['ai_summary']) : null,
      aiGenerated: json['ai_generated'] ?? false,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static Map<String, double> _parseLocation(dynamic locationData) {
    if (locationData == null) return {'lat': 0.0, 'lng': 0.0};

    if (locationData is Map) {
      return {
        'lat': (locationData['lat'] ?? locationData['latitude'] ?? 0.0).toDouble(),
        'lng': (locationData['lng'] ?? locationData['longitude'] ?? 0.0).toDouble(),
      };
    }
    return {'lat': 0.0, 'lng': 0.0};
  }

  static DateTime _parseDateTime(dynamic dateData) {
    if (dateData == null) return DateTime.now();

    if (dateData is String) {
      return DateTime.tryParse(dateData) ?? DateTime.now();
    } else if (dateData is Map && dateData['\$date'] != null) {
      // Formato MongoDB ISODate
      return DateTime.tryParse(dateData['\$date'].toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'plant_type': plantType,
      'prediction': prediction,
      'class_id': classId,
      'confidence': confidence,
      'location': location,
      'image_id': imageId,
      'ai_response': aiResponse,
      'ai_summary': aiSummary,
      'ai_generated': aiGenerated,
      'created_at': createdAt.toIso8601String(),
    };
  }


  // Métodos de conveniencia
  String get diseaseName => prediction;

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isHealthy => prediction.toLowerCase().contains('healthy');

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Para mostrar en UI
  String get displayName {
    return prediction.replaceAll('_', ' ').split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Factory para crear desde la respuesta de upload
  factory PlantAnalysisModel.fromUploadResponse(Map<String, dynamic> response) {
    return PlantAnalysisModel(
      id: response['analysis_id'] ?? '',
      userId: '', // Se llena después
      plantType: response['plant_type'] ?? 'tomato',
      prediction: response['prediction'] ?? 'Desconocido',
      classId: response['class_id']?.toInt(),
      confidence: (response['confidence'] ?? 0.0).toDouble(),
      location: {'lat': 0.0, 'lng': 0.0}, // Se llena después
      imageId: response['image_id'] ?? '',
      createdAt: DateTime.now(),
    );
  }

  String get plantDisplayName {
    switch (plantType?.toLowerCase() ?? 'tomato') {
      case 'tomato':
        return 'Tomate';
      case 'potato':
        return 'Papa';
      case 'pepper':
        return 'Pimiento';
      default:
        return 'Planta';
    }
  }

  // Copiar con nuevos valores
  PlantAnalysisModel copyWith({
    String? id,
    String? userId,
    String? plantType,
    String? prediction,
    int? classId,
    double? confidence,
    Map<String, double>? location,
    String? imageId,
    Map<String, dynamic>? aiResponse,
    Map<String, dynamic>? aiSummary,
    bool? aiGenerated,
    DateTime? createdAt,
  }) {
    return PlantAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plantType: plantType ?? this.plantType,
      prediction: prediction ?? this.prediction,
      classId: classId ?? this.classId,
      confidence: confidence ?? this.confidence,
      location: location ?? this.location,
      imageId: imageId ?? this.imageId,
      aiResponse: aiResponse ?? this.aiResponse,
      aiSummary: aiSummary ?? this.aiSummary,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PlantAnalysisModel(id: $id, plantType: $plantType, prediction: $prediction, confidence: $confidence)';
  }
}

// Modelo para respuesta de análisis con IA
class AIAnalysisResponse {
  final String analysisId;
  final String plantType;
  final String prediction;
  final double confidence;
  final bool aiGenerated;
  final Map<String, dynamic>? aiResponse;

  AIAnalysisResponse({
    required this.analysisId,
    required this.plantType,
    required this.prediction,
    required this.confidence,
    required this.aiGenerated,
    this.aiResponse,
  });

  factory AIAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResponse(
      analysisId: json['analysis_id']?.toString() ?? '',
      plantType: json['plant_type']?.toString() ?? 'tomato',
      prediction: json['prediction']?.toString() ?? 'Desconocido',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      aiGenerated: json['ai_generated'] ?? false,
      aiResponse: json['ai_response'] is Map
          ? Map<String, dynamic>.from(json['ai_response'])
          : null,
    );
  }

  PlantAnalysisModel toPlantAnalysisModel({
    required String userId,
    required Map<String, double> location,
    required String imageId,
  }) {
    return PlantAnalysisModel(
      id: analysisId,
      userId: userId,
      plantType: plantType,
      prediction: prediction,
      confidence: confidence,
      location: location,
      imageId: imageId,
      aiResponse: aiResponse,
      aiGenerated: aiGenerated,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'plant_type': plantType,
      'prediction': prediction,
      'confidence': confidence,
      'ai_generated': aiGenerated,
      'ai_response': aiResponse,
      'message': 'Análisis generado con IA',
    };
  }
}