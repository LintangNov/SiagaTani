import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm_model.dart';

class FirestoreService {
  final CollectionReference _farmsCollection = 
      FirebaseFirestore.instance.collection('farms');

  // Simpan Lahan Baru
  Future<void> addFarm(FarmModel farm) async {
    try {
      await _farmsCollection.add(farm.toMap());
    } catch (e) {
      print("Error adding farm: $e");
      throw e;
    }
  }

  // Ambil Semua Lahan (Stream agar realtime update di dashboard)
  Stream<List<FarmModel>> getFarms() {
    return _farmsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FarmModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  
  // Hapus Lahan (Opsional)
  Future<void> deleteFarm(String id) async {
    await _farmsCollection.doc(id).delete();
  }
}