import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/freight.dart';
import '../../core/providers/connectivity_provider.dart';
import '../freight/publish_freight_screen.dart';
import '../location/location_service.dart';
import 'map_controller.dart';
import 'widgets/freight_bottom_sheet.dart';
import 'widgets/radius_filter_dropdown.dart';
import 'widgets/zone_filter_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  static const _defaultPosition = CameraPosition(
    target: LatLng(-34.6037, -58.3816), // Buenos Aires
    zoom: 11,
  );

  Set<Marker> _buildMarkers(List<Freight> freights) {
    return {
      for (final f in freights)
        Marker(
          markerId: MarkerId(f.id),
          position: LatLng(f.geoPoint.latitude, f.geoPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(_statusToHue(f.status)),
          onTap: () => ref.read(selectedFreightProvider.notifier).state = f,
        ),
    };
  }

  double _statusToHue(String status) => switch (status) {
        'available' => BitmapDescriptor.hueGreen,
        'assigned' => BitmapDescriptor.hueOrange,
        'completed' => BitmapDescriptor.hueAzure,
        _ => BitmapDescriptor.hueBlue,
      };

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    ref.read(userLocationProvider.future).then((gp) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(gp.geopoint.latitude, gp.geopoint.longitude),
        ),
      );
    });
  }

  void _openZoneFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const ZoneFilterSheet(),
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(userLocationProvider);
    ref.invalidate(nearbyFreightProvider);
  }

  @override
  Widget build(BuildContext context) {
    final freightsAsync = ref.watch(nearbyFreightProvider);
    final selected = ref.watch(selectedFreightProvider);
    final activeZone = ref.watch(zoneFilterProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreteMap'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: RadiusFilterDropdown(),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.location_city),
                tooltip: 'Filtrar por zona',
                onPressed: _openZoneFilter,
              ),
              if (activeZone != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            MaterialBanner(
              content: const Text('Sin conexión — los fletes pueden estar desactualizados'),
              backgroundColor: Colors.orange[100],
              leading: const Icon(Icons.wifi_off, color: Colors.orange),
              actions: [
                TextButton(
                  onPressed: _onRefresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Stack(
                children: [
                  freightsAsync.when(
                    data: (freights) => GoogleMap(
                      initialCameraPosition: _defaultPosition,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _buildMarkers(freights),
                      onTap: (_) =>
                          ref.read(selectedFreightProvider.notifier).state = null,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _MapError(onRetry: _onRefresh),
                  ),
                  if (activeZone != null)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Chip(
                          avatar: const Icon(Icons.location_on, size: 16),
                          label: Text(activeZone),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              ref.read(zoneFilterProvider.notifier).state = null,
                          backgroundColor: Colors.white,
                          elevation: 4,
                        ),
                      ),
                    ),
                  if (selected != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Material(
                        elevation: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: const FreightBottomSheet(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PublishFreightScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Publicar flete'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _MapError extends StatelessWidget {
  const _MapError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar los fletes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verificá tu conexión e intentá de nuevo.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
