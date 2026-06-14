import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/freight.dart';
import '../../core/services/firestore_service.dart';
import '../location/location_service.dart';

final radiusProvider = StateProvider<double>((ref) => 10.0);

final statusFilterProvider = StateProvider<String?>((ref) => null);

final zoneFilterProvider = StateProvider<String?>((ref) => null);

final nearbyFreightProvider = StreamProvider<List<Freight>>((ref) {
  final locationAsync = ref.watch(userLocationProvider);
  final radiusKm = ref.watch(radiusProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final zoneFilter = ref.watch(zoneFilterProvider);
  final service = ref.watch(firestoreServiceProvider);

  return locationAsync.when(
    data: (geoPoint) => service.nearbyStream(
      center: geoPoint,
      radiusKm: radiusKm,
      statusFilter: statusFilter,
      zoneFilter: zoneFilter,
    ),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final selectedFreightProvider = StateProvider<Freight?>((ref) => null);
