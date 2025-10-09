import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/hotline.dart';

final hotlineProvider = FutureProvider<List<HotlineCategory>>((ref) async {
  final response = await http.get(
    Uri.parse('https://emergencynumberapi.com/api/country/PH'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return _parseHotlines(data);
  } else {
    throw Exception('Failed to load hotlines');
  }
});

List<HotlineCategory> _parseHotlines(Map<String, dynamic> data) {
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
