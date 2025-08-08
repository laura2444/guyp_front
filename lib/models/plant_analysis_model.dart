class PlantAnalysisModel {
  final String id;
  final String userId;
  final String prediction;
  final Map<String, double> location;
  final String imageUrl;
  final DateTime createdAt;

  PlantAnalysisModel({
    required this.id,
    required this.userId,
    required this.prediction,
    required this.location,
    required this.imageUrl,
    required this.createdAt,
  });

  factory PlantAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PlantAnalysisModel(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      prediction: json['prediction'] ?? '',
      location: (json['location'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())), 
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'prediction': prediction,
      'location': location,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
