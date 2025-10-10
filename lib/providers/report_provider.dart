import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/disaster_report.dart';

final reportProvider = FutureProvider<List<DisasterReport>>((ref) async {
  // Broader query for testing (remove $filter to get all disasters, filter for 'Flood' in code)
  final uri =
      Uri.parse(
        'https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries',
      ).replace(
        queryParameters: {
          '\$limit': '10', // Corrected to escape $ with \$
        },
      );
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    final summaries = data['DisasterDeclarationsSummaries'] as List?;
    if (summaries == null || summaries.isEmpty) {
      return []; // Return empty list instead of throwing
    }
    // Filter for flood reports in code
    final reports = summaries
        .where(
          (json) => (json['incidentType'] as String?)?.toLowerCase() == 'flood',
        )
        .map((json) => DisasterReport.fromJson(json))
        .toList();
    return reports;
  } else {
    throw Exception(
      'Failed to load flood reports: Status ${response.statusCode}',
    );
  }
});
