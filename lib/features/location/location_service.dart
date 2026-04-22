import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final userLocationProvider = FutureProvider<GeoFirePoint?>((ref) async {
  return LocationService.instance.currentGeoFirePoint();
});

class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Future<GeoFirePoint?> currentGeoFirePoint() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return GeoFirePoint(GeoPoint(position.latitude, position.longitude));
  }

  /// Continuous stream — stub for future delivery-tracking feature.
  Stream<GeoFirePoint> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).map((p) => GeoFirePoint(GeoPoint(p.latitude, p.longitude)));
  }
}
