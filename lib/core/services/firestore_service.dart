import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../models/freight.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

class FirestoreService {
  FirestoreService()
      : _freights = FirebaseFirestore.instance
            .collection('freights')
            .withConverter<Freight>(
              fromFirestore: Freight.fromFirestore,
              toFirestore: (f, _) => f.toFirestore(),
            );

  final CollectionReference<Freight> _freights;

  /// Real-time stream of freight within [radiusKm] of [center].
  /// Status and zone filtering are client-side to avoid composite Firestore indexes in v1.
  Stream<List<Freight>> nearbyStream({
    required GeoFirePoint center,
    required double radiusKm,
    String? statusFilter,
    String? zoneFilter,
  }) {
    final geoRef = GeoCollectionReference<Freight>(_freights);
    return geoRef
        .subscribeWithin(
          center: center,
          radiusInKm: radiusKm,
          field: 'location',
          geopointFrom: (f) => f.geoPoint,
          strictMode: true,
        )
        .map(
          (docs) => docs
              .map((doc) => doc.data()!)
              .where((f) => statusFilter == null || f.status == statusFilter)
              .where((f) => zoneFilter == null ||
                  f.zone.toLowerCase() == zoneFilter.toLowerCase())
              .toList(),
        );
  }

  Future<void> publishFreight(Freight freight) =>
      _freights.doc(freight.id).set(freight);

  Future<void> updateStatus(String id, String newStatus) =>
      _freights.doc(id).update({'status': newStatus});

  Future<void> deleteFreight(String id) => _freights.doc(id).delete();
}
