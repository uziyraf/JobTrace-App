import 'package:jobtracker/core/sqlite_helper.dart';
import 'package:jobtracker/data/models/schedule_model.dart';

class ScheduleDao {
  Future<int> insertSchedule(ScheduleModel schedule) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<ScheduleModel>> getAllSchedules() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('schedules', orderBy: 'id DESC');
    return result.map((json) => ScheduleModel.fromMap(json)).toList();
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('schedules', schedule.toMap(),
        where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> deleteSchedule(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }
}
