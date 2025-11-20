import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- COLLECTION: LAHAN CABAI (FARMS) ---
  final CollectionReference _farmsCollection = 
      FirebaseFirestore.instance.collection('farms');

  Future<void> addFarm(FarmModel farm) async {
    await _farmsCollection.add(farm.toMap());
  }

  Stream<List<FarmModel>> getFarms() {
    return _farmsCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FarmModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- COLLECTION: PIN TANAMAN SEKITAR (SURROUNDING PINS) ---
  final CollectionReference _pinsCollection = 
      FirebaseFirestore.instance.collection('surrounding_pins');

  // 1. Tambah Pin Baru
  Future<void> addSurroundingPin(SurroundingPinModel pin) async {
    await _pinsCollection.add(pin.toMap());
  }

  // 2. Ambil Semua Pin (Sekali panggil atau Stream)
  Future<List<SurroundingPinModel>> getAllPins() async {
    final snapshot = await _pinsCollection.get();
    return snapshot.docs.map((doc) {
      return SurroundingPinModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
  
  // Stream agar map update realtime saat user nambah pin
  Stream<List<SurroundingPinModel>> getPinsStream() {
    return _pinsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SurroundingPinModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}