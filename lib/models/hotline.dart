import 'package:flutter/material.dart';

class Hotline {
  final String name;
  final String number;
  const Hotline({required this.name, required this.number});
}

class HotlineCategory {
  final String name;
  final IconData icon;
  final List<Hotline> hotlines;
  const HotlineCategory({
    required this.name,
    required this.icon,
    required this.hotlines,
  });
}
