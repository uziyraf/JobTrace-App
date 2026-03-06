import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobtracker/data/models/schedule_model.dart';

class ScheduleDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> insertSchedule(ScheduleModel schedule) async {
    final int generatedId =
        schedule.id ?? DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> data = schedule.toMap();
    data['id'] = generatedId;

    await _firestore
        .collection('schedules')
        .doc(generatedId.toString())
        .set(data);

    return generatedId;
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    final snapshot = await _firestore
        .collection('schedules')
        .orderBy('id', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ScheduleModel.fromMap(doc.data()))
        .toList();
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    if (schedule.id == null) return 0;

    await _firestore
        .collection('schedules')
        .doc(schedule.id.toString())
        .update(schedule.toMap());

    return schedule.id!;
  }

  Future<int> deleteSchedule(int id) async {
    await _firestore.collection('schedules').doc(id.toString()).delete();
    return id;
  }
}
