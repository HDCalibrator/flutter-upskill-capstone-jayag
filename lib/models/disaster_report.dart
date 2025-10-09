import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/hotline.dart'; // Your models

final hotlineProvider = FutureProvider<List<HotlineCategory>>((ref) async {
  final response = await http.get(
    Uri.parse('https://emergencynumberapi.com/api/country/PH'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Parse to your models (map police/fire/medical to categories)
    return _parseHotlines(data);
  } else {
    throw Exception('Failed to load hotlines');
  }
});

List<HotlineCategory> _parseHotlines(Map<String, dynamic> data) {
  // Example parsing for PH
  return [
    HotlineCategory(
      name: 'Police',
      icon: Icons.local_police,
      hotlines: [
        Hotline(
          name: 'National Police Hotline',
          number: data['police']['all'][0] ?? '117',
        ),
      ],
    ),
    HotlineCategory(
      name: 'Fire',
      icon: Icons.local_fire_department,
      hotlines: [
        Hotline(
          name: 'Fire Department',
          number: data['fire']['all'][0] ?? '144',
        ),
      ],
    ),
    HotlineCategory(
      name: 'Medical',
      icon: Icons.local_hospital,
      hotlines: [
        Hotline(name: 'Ambulance', number: data['medical']['all'][0] ?? '911'),
      ],
    ),
  ];
}

class DisasterReport {
  final String disasterNumber;
  final DateTime declarationDate;
  final String incidentType;
  final String state;
  final String designatedArea;
  final String declarationTitle;

  DisasterReport({
    required this.disasterNumber,
    required this.declarationDate,
    required this.incidentType,
    required this.state,
    required this.designatedArea,
    required this.declarationTitle,
  });

  // Factory constructor to create from JSON
  factory DisasterReport.fromJson(Map<String, dynamic> json) {
    return DisasterReport(
      disasterNumber: json['disasterNumber'] as String? ?? 'N/A',
      declarationDate: DateTime.parse(json['declarationDate'] as String),
      incidentType: json['incidentType'] as String? ?? 'Unknown',
      state: json['state'] as String? ?? 'Unknown',
      designatedArea: json['designatedArea'] as String? ?? 'Unknown',
      declarationTitle: json['declarationTitle'] as String? ?? 'No Title',
    );
  }
}
