import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/flood_risk_report.dart';

final floodRiskProvider = FutureProvider<List<FloodRiskReport>>((ref) async {
  final uri = Uri.parse('https://api.openweathermap.org/data/2.5/onecall').replace(
    queryParameters: {
      'lat': '15.15', // Arayat lat
      'lon': '120.77', // Arayat lng
      'appid':
          'b6907d289e10d714a6e88b30761fae22', // Free API key (public for testing)
      'units': 'metric',
      'exclude': 'current,minutely,daily,alerts', // Hourly only
    },
  );
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    final hourly = data['hourly'] as List? ?? [];
    final reports = hourly
        .sublist(0, 10) // Limit to next 10 hours
        .map((hour) => FloodRiskReport.fromJson(hour))
        .toList();
    return reports;
  } else {
    throw Exception(
      'Failed to load flood risk data: Status ${response.statusCode}',
    );
  }
});
