class ApplicationModel {
  final int? id; // ID otomatis dari SQLite
  final String company;
  final String role;
  final String status;
  final String platform;
  final String dateApplied;
  final String? evaluation;
  final String? notes;

  ApplicationModel({
    this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.platform,
    required this.dateApplied,
    this.evaluation,
    this.notes,
  });

  // Mengubah data Model menjadi Map (Format yang diterima SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'role': role,
      'status': status,
      'platform': platform,
      'dateApplied': dateApplied,
      'evaluation': evaluation,
      'notes': notes,
    };
  }

  // Mengubah data dari SQLite (Map) kembali menjadi Model
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'],
      company: map['company'],
      role: map['role'],
      status: map['status'],
      platform: map['platform'],
      dateApplied: map['dateApplied'],
      evaluation: map['evaluation'],
      notes: map['notes'],
    );
  }
}
