import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';

class FirestoreService {
  final CollectionReference _farmsCollection = FirebaseFirestore.instance
      .collection('farms');
  final CollectionReference _pinsCollection = FirebaseFirestore.instance
      .collection('surrounding_pins');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ── Farm CRUD ──────────────────────────────────────────────

  Future<void> addFarm(FarmModel farm) async {
    final String? uid = _currentUserId;
    if (uid == null) throw Exception('User belum login!');

    final Map<String, dynamic> data = _farmToFirestore(farm);
    data['userId'] = uid;

    await _farmsCollection.add(data);
  }

  Future<void> updateFarmName(String id, String newName) async {
    await _farmsCollection.doc(id).update({'farmName': newName});
  }

  Future<void> updateFarmPhase(
    String id,
    String newPhaseStr,
    String newEnumStr,
  ) async {
    await _farmsCollection.doc(id).update({
      'currentPhase': newPhaseStr,
      'cropStage': newEnumStr,
    });
  }

  Future<void> deleteFarm(String id) async {
    await _farmsCollection.doc(id).delete();
  }

  Stream<List<FarmModel>> getFarms() {
    final String? uid = _currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _farmsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return _farmFromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ── Surrounding Pins ───────────────────────────────────────

  Future<void> addSurroundingPin(SurroundingPinModel pin) async {
    await _pinsCollection.add(_pinToFirestore(pin));
  }

  Future<List<SurroundingPinModel>> getAllPins() async {
    final snapshot = await _pinsCollection.get();
    return snapshot.docs.map((doc) {
      return _pinFromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Stream<List<SurroundingPinModel>> getPinsStream() {
    return _pinsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return _pinFromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ── Firestore ↔ Model Converters ──────────────────────────
  // Firestore-specific types (GeoPoint, FieldValue) are handled here,
  // keeping the model classes as pure Dart.

  Map<String, dynamic> _farmToFirestore(FarmModel farm) {
    final json = farm.toJson();
    // Replace flat lat/lng with Firestore GeoPoint
    json.remove('latitude');
    json.remove('longitude');
    json['location'] = GeoPoint(farm.latitude, farm.longitude);
    json['createdAt'] = FieldValue.serverTimestamp();
    return json;
  }

  FarmModel _farmFromFirestore(Map<String, dynamic> data, String docId) {
    // Convert Firestore GeoPoint back to flat lat/lng
    final GeoPoint geoPoint = data['location'] as GeoPoint;
    final Map<String, dynamic> json = Map<String, dynamic>.from(data);
    json['latitude'] = geoPoint.latitude;
    json['longitude'] = geoPoint.longitude;
    return FarmModel.fromJson(json, docId);
  }

  Map<String, dynamic> _pinToFirestore(SurroundingPinModel pin) {
    final json = pin.toJson();
    json.remove('latitude');
    json.remove('longitude');
    json['location'] = GeoPoint(pin.latitude, pin.longitude);
    json['createdAt'] = FieldValue.serverTimestamp();
    return json;
  }

  SurroundingPinModel _pinFromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    final GeoPoint geo = data['location'] as GeoPoint;
    final Map<String, dynamic> json = Map<String, dynamic>.from(data);
    json['latitude'] = geo.latitude;
    json['longitude'] = geo.longitude;
    return SurroundingPinModel.fromJson(json, docId);
  }
}
