import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginStateProvider = StateProvider<bool>((ref) => false);
final themeProvider = StateProvider<bool>((ref) => true); // true = dark mode
