import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/weather_report.dart';

final weatherProvider = FutureProvider<List<WeatherReport>>((ref) async {
  final uri = Uri.parse('https://api.open-meteo.com/v1/forecast').replace(
    queryParameters: {
      'latitude': '15.15', // Arayat, Pampanga latitude
      'longitude': '120.77', // Arayat, Pampanga longitude
      'hourly':
          'temperature_2m,precipitation', // Hourly temperature and precipitation
      'timezone': 'Asia/Manila', // Local timezone
      'forecast_days': '1', // Limit to 1 day (24 hours) of data
    },
  );
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>? ?? {};
    final times = hourly['time'] as List? ?? [];
    final temperatures = hourly['temperature_2m'] as List? ?? [];
    final precipitations = hourly['precipitation'] as List? ?? [];
    final reports = <WeatherReport>[];
    for (int i = 0; i < times.length; i++) {
      reports.add(
        WeatherReport(
          time: DateTime.parse(times[i]),
          temperature: temperatures[i].toDouble(),
          precipitation: precipitations[i].toDouble(),
          condition: precipitations[i] > 0
              ? 'Rain: ${precipitations[i]}mm/h'
              : 'Clear',
          location: 'Arayat, Pampanga', // Hardcoded location
        ),
      );
    }
    // Include current hour and next 9 hours
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 8),
    ); // Convert PST to PHT
    final currentHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ); // Round to current hour
    return reports
        .where(
          (report) => report.time.isAfter(
            currentHour.subtract(const Duration(hours: 1)),
          ),
        ) // Include current hour
        .take(10)
        .toList();
  } else {
    throw Exception(
      'Failed to load weather data: Status ${response.statusCode}',
    );
  }
});
