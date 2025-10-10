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
      disasterNumber: json['disasterNumber']
          .toString(), // Convert int to String
      declarationDate:
          DateTime.tryParse(json['declarationDate'] as String) ??
          DateTime.now(), // Updated line
      incidentType: json['incidentType'] as String? ?? 'Unknown',
      state: json['state'] as String? ?? 'Unknown',
      designatedArea: json['designatedArea'] as String? ?? 'Unknown',
      declarationTitle: json['declarationTitle'] as String? ?? 'No Title',
    );
  }
}
