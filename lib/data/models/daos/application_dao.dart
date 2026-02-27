import 'package:jobtracker/core/sqlite_helper.dart';
import 'package:jobtracker/data/models/application_model.dart';

class ApplicationDao {
  // Pinjam koneksi dari Helper
  Future<int> insertApplication(ApplicationModel app) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('applications', app.toMap());
  }

  Future<List<ApplicationModel>> getAllApplications() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('applications', orderBy: 'id DESC');
    return result.map((json) => ApplicationModel.fromMap(json)).toList();
  }

  Future<int> updateApplication(ApplicationModel app) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('applications', app.toMap(),
        where: 'id = ?', whereArgs: [app.id]);
  }

  Future<int> deleteApplication(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('applications', where: 'id = ?', whereArgs: [id]);
  }
}
