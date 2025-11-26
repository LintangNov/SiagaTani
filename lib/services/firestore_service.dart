import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Wajib import ini
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';

class FirestoreService {
  final CollectionReference _farmsCollection = 
      FirebaseFirestore.instance.collection('farms');
  final CollectionReference _pinsCollection = 
      FirebaseFirestore.instance.collection('surrounding_pins');

  // Helper untuk ambil User ID saat ini
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addFarm(FarmModel farm) async {
    String? uid = _currentUserId;
    if (uid == null) throw Exception("User belum login!");

    // 2. Saat simpan, tempelkan 'userId' ke data
    Map<String, dynamic> data = farm.toMap();
    data['userId'] = uid; 
    
    await _farmsCollection.add(data);
  }

  Future<void> updateFarmName(String id, String newName) async {
    await _farmsCollection.doc(id).update({'farmName': newName});
  }

  Future<void> deleteFarm(String id) async {
    await _farmsCollection.doc(id).delete();
  }

  Stream<List<FarmModel>> getFarms() {
    String? uid = _currentUserId;
    
    if (uid == null) {
      // Kalau user logout/null, kembalikan list kosong
      return Stream.value([]); 
    }

    // 3. Saat ambil data, FILTER berdasarkan 'userId' == uid saya
    return _farmsCollection
        .where('userId', isEqualTo: uid) // INI KUNCINYA
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FarmModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- PIN TETANGGA (Biasanya bersifat publik/berbagi, jadi tidak perlu filter user) ---
  // Tapi kalau mau privat juga, lakukan hal yang sama seperti di atas.
  
  Future<void> addSurroundingPin(SurroundingPinModel pin) async {
    await _pinsCollection.add(pin.toMap());
  }

  Future<List<SurroundingPinModel>> getAllPins() async {
    final snapshot = await _pinsCollection.get();
    return snapshot.docs.map((doc) {
      return SurroundingPinModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
  
  Stream<List<SurroundingPinModel>> getPinsStream() {
    return _pinsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SurroundingPinModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}