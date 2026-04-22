import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/freight.dart';
import '../../core/services/firestore_service.dart';
import '../location/location_service.dart';

final radiusProvider = StateProvider<double>((ref) => 10.0);

final statusFilterProvider = StateProvider<String?>((ref) => null);

final nearbyFreightProvider = StreamProvider<List<Freight>>((ref) {
  final locationAsync = ref.watch(userLocationProvider);
  final radiusKm = ref.watch(radiusProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final service = ref.watch(firestoreServiceProvider);

  return locationAsync.when(
    data: (geoPoint) {
      if (geoPoint == null) return const Stream.empty();
      return service.nearbyStream(
        center: geoPoint,
        radiusKm: radiusKm,
        statusFilter: statusFilter,
      );
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final selectedFreightProvider = StateProvider<Freight?>((ref) => null);
