class ApplicationModel {
  final String? id; // Di Firebase, ID biasanya String (Document ID)
  final String company;
  final String role;
  final String status;
  final String platform;
  final String dateApplied;
  final String? evaluation;
  final String? notes;

  // Field Tambahan buat Fitur Skill Match
  final List<String> requiredSkills;
  final double matchPercentage;

  ApplicationModel({
    this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.platform,
    required this.dateApplied,
    this.evaluation,
    this.notes,
    this.requiredSkills = const [], // Default list kosong
    this.matchPercentage = 0.0,
  });

  // Konversi dari Object ke Map (buat dikirim ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'role': role,
      'status': status,
      'platform': platform,
      'dateApplied': dateApplied,
      'evaluation': evaluation,
      'notes': notes,
      'requiredSkills': requiredSkills,
      'matchPercentage': matchPercentage,
    };
  }

  // Konversi dari Map/DocumentSnapshot ke Object (buat ditarik dari Firestore)
  factory ApplicationModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return ApplicationModel(
      id: documentId,
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? 'Applied',
      platform: map['platform'] ?? 'LinkedIn',
      dateApplied: map['dateApplied'] ?? '',
      evaluation: map['evaluation'],
      notes: map['notes'],
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      matchPercentage: (map['matchPercentage'] ?? 0.0).toDouble(),
    );
  }
}
