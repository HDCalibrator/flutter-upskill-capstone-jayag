class WeatherReport {
  final DateTime time;
  final double temperature;
  final double precipitation;
  final String condition;
  final String location; // New field for area

  WeatherReport({
    required this.time,
    required this.temperature,
    required this.precipitation,
    required this.condition,
    required this.location,
  });
}
