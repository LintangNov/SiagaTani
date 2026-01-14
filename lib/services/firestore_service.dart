import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';

class FirestoreService {
  final CollectionReference _farmsCollection = 
      FirebaseFirestore.instance.collection('farms');
  final CollectionReference _pinsCollection = 
      FirebaseFirestore.instance.collection('surrounding_pins');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addFarm(FarmModel farm) async {
    String? uid = _currentUserId;
    if (uid == null) throw Exception("User belum login!");

    Map<String, dynamic> data = farm.toMap();
    data['userId'] = uid; 
    
    await _farmsCollection.add(data);
  }

  Future<void> updateFarmName(String id, String newName) async {
    await _farmsCollection.doc(id).update({'farmName': newName});
  }

  Future<void> updateFarmPhase(String id, String newPhaseStr, String newEnumStr) async {
    await _farmsCollection.doc(id).update({
      'currentPhase': newPhaseStr,
      'cropStage': newEnumStr,
    });
  }

  Future<void> deleteFarm(String id) async {
    await _farmsCollection.doc(id).delete();
  }

  Stream<List<FarmModel>> getFarms() {
    String? uid = _currentUserId;
    
    if (uid == null) {
      return Stream.value([]); 
    }

    return _farmsCollection
        .where('userId', isEqualTo: uid) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
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