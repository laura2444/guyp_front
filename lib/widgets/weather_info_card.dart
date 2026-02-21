import 'package:flutter/material.dart';
import 'package:store_app/models/weather_model.dart';

/// Tarjeta reutilizable que muestra la información meteorológica del lugar
/// donde se realizó el análisis. Diseño claro con temperatura destacada,
/// ubicación, condición y métricas en grid.
class WeatherInfoCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherInfoCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.shade50,
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        border: Border.all(
          color: Colors.cyan.shade100.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildLocationAndTime(),
              const SizedBox(height: 20),
              _buildTemperatureBlock(),
              const SizedBox(height: 18),
              _buildConditionBadge(),
              const SizedBox(height: 18),
              _buildMetricsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.shade200.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.cloud_rounded,
            size: 24,
            color: Colors.cyan.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CLIMA EN EL LUGAR DEL ANÁLISIS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.cyan.shade800,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Condiciones al momento del análisis',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndTime() {
    final hasLocation = weather.locationDisplay.isNotEmpty;
    final hasTime = weather.time.isNotEmpty;

    if (!hasLocation && !hasTime) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 18,
          color: Colors.cyan.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLocation)
                Text(
                  weather.locationDisplay,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              if (hasLocation && hasTime) const SizedBox(height: 2),
              if (hasTime)
                Text(
                  weather.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureBlock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather.temperature}°',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
                height: 1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sensación ${weather.feelslike}°C',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: weather.isDay == 1
                ? Colors.amber.shade100
                : Colors.indigo.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: weather.isDay == 1
                  ? Colors.amber.shade300
                  : Colors.indigo.shade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                weather.isDay == 1 ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 16,
                color: weather.isDay == 1
                    ? Colors.amber.shade800
                    : Colors.indigo.shade800,
              ),
              const SizedBox(width: 4),
              Text(
                weather.dayNightLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: weather.isDay == 1
                      ? Colors.amber.shade900
                      : Colors.indigo.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionBadge() {
    if (weather.condition.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_cloudy_rounded,
            size: 20,
            color: Colors.cyan.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              weather.condition,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            icon: Icons.water_drop_rounded,
            value: '${weather.humidity}%',
            label: 'Humedad',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricItem(
            icon: Icons.air_rounded,
            value: '${weather.windspeed}',
            label: 'Viento km/h',
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricItem(
            icon: Icons.explore_rounded,
            value: '${weather.winddirection}°',
            label: 'Dirección',
            color: Colors.cyan,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color.shade700),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
