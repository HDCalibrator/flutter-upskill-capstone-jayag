class FloodRiskReport {
  final DateTime time;
  final double precipitation; // mm/h (higher = higher flood risk)
  final String location; // e.g., "Arayat, Pampanga"
  final String riskLevel; // Derived: "Low", "Medium", "High"

  FloodRiskReport({
    required this.time,
    required this.precipitation,
    required this.location,
    required this.riskLevel,
  });

  factory FloodRiskReport.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    final times = hourly['time'] as List? ?? [];
    final precip = hourly['precipitation'] as List? ?? [];
    final index = times.indexWhere((t) => t == json['time']);
    return FloodRiskReport(
      time: DateTime.parse(json['time'] as String),
      precipitation: (precip[index] as num).toDouble(),
      location: 'Arayat, Pampanga', // Hardcoded for now; can be dynamic
      riskLevel: _calculateRisk((precip[index] as num).toDouble()),
    );
  }

  static String _calculateRisk(double precip) {
    if (precip < 5) return 'Low';
    if (precip < 20) return 'Medium';
    return 'High';
  }
}
