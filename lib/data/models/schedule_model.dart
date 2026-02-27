class ScheduleModel {
  final int? id;
  final int jobId; // Untuk menyambungkan jadwal dengan data lamaran (Relasi)
  final String company;
  final String role;
  final String date;
  final String time;
  final String platform;
  final String status; // 'UPCOMING' atau 'COMPLETED'

  ScheduleModel({
    this.id,
    required this.jobId,
    required this.company,
    required this.role,
    required this.date,
    required this.time,
    required this.platform,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'company': company,
      'role': role,
      'date': date,
      'time': time,
      'platform': platform,
      'status': status,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      jobId: map['jobId'],
      company: map['company'],
      role: map['role'],
      date: map['date'],
      time: map['time'],
      platform: map['platform'],
      status: map['status'],
    );
  }
}
