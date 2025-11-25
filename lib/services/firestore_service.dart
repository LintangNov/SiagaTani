import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';

class FirestoreService {
  final CollectionReference _farmsCollection = 
      FirebaseFirestore.instance.collection('farms');
  final CollectionReference _pinsCollection = 
      FirebaseFirestore.instance.collection('surrounding_pins');

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