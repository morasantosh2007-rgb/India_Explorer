import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/state_model.dart';
import '../models/city_model.dart';
import '../models/famous_place_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get states
  Stream<List<StateModel>> getStates() {
    return _db.collection('states').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StateModel.fromMap(doc.data())).toList());
  }

  // Get cities of a state
  Stream<List<CityModel>> getCities(String stateName) {
    return _db
        .collection('states')
        .doc(stateName)
        .collection('cities')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CityModel.fromMap(doc.data())).toList());
  }

  // Get famous places of a city
  Stream<List<FamousPlaceModel>> getFamousPlaces(
      String stateName, String cityName) {
    return _db
        .collection('states')
        .doc(stateName)
        .collection('cities')
        .doc(cityName)
        .collection('famous_places')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FamousPlaceModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}