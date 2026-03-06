import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobtracker/data/models/application_model.dart';

class ApplicationDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> insertApplication(ApplicationModel app) async {
    final int generatedId = app.id ?? DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> data = app.toMap();
    data['id'] = generatedId;

    await _firestore
        .collection('applications')
        .doc(generatedId.toString())
        .set(data);

    return generatedId;
  }

  Future<List<ApplicationModel>> getAllApplications() async {
    // Ambil data dari cloud, urutkan dari yang terbaru (ID terbesar)
    final snapshot = await _firestore
        .collection('applications')
        .orderBy('id', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ApplicationModel.fromMap(doc.data()))
        .toList();
  }

  Future<int> updateApplication(ApplicationModel app) async {
    if (app.id == null) return 0;

    // Update data di cloud berdasarkan ID-nya
    await _firestore
        .collection('applications')
        .doc(app.id.toString())
        .update(app.toMap());

    return app.id!;
  }

  Future<int> deleteApplication(int id) async {
    await _firestore.collection('applications').doc(id.toString()).delete();
    return id;
  }
}
