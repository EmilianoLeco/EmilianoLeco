import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/freight.dart';
import '../freight/publish_freight_screen.dart';
import '../location/location_service.dart';
import 'map_controller.dart';
import 'widgets/freight_bottom_sheet.dart';
import 'widgets/radius_filter_dropdown.dart';

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
      if (gp == null || _mapController == null) return;
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(gp.geopoint.latitude, gp.geopoint.longitude),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final freightsAsync = ref.watch(nearbyFreightProvider);
    final selected = ref.watch(selectedFreightProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreteMap'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: RadiusFilterDropdown(),
          ),
        ],
      ),
      body: Stack(
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
            error: (e, _) => Center(child: Text('Error: $e')),
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
