/// Modelo para la información meteorológica del lugar del análisis.
/// Proviene de la API de clima que el backend consulta e integra en la respuesta.
class WeatherModel {
  final num temperature;
  final num humidity;
  final num windspeed;
  final num winddirection;
  final int isDay;
  final String condition;
  final num feelslike;
  final String time;
  final String locationName;
  final String region;
  final String country;

  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.windspeed,
    required this.winddirection,
    required this.isDay,
    required this.condition,
    required this.feelslike,
    required this.time,
    required this.locationName,
    required this.region,
    required this.country,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: _numFrom(json['temperature']),
      humidity: _numFrom(json['humidity']),
      windspeed: _numFrom(json['windspeed']),
      winddirection: _numFrom(json['winddirection']),
      isDay: int.tryParse('${json['is_day'] ?? json['isDay'] ?? 0}') ?? 0,
      condition: json['condition']?.toString() ?? '',
      feelslike: _numFrom(json['feelslike']),
      time: json['time']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? json['locationName']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }

  static num _numFrom(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  /// Etiqueta día/noche según is_day (1 = día, 0 = noche).
  String get dayNightLabel => isDay == 1 ? 'Día' : 'Noche';

  /// Ubicación formateada: ciudad, región, país.
  String get locationDisplay {
    final parts = <String>[];
    if (locationName.isNotEmpty) parts.add(locationName);
    if (region.isNotEmpty) parts.add(region);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windspeed': windspeed,
      'winddirection': winddirection,
      'is_day': isDay,
      'condition': condition,
      'feelslike': feelslike,
      'time': time,
      'location_name': locationName,
      'region': region,
      'country': country,
    };
  }
}
