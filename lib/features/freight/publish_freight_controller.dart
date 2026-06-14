import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/freight.dart';
import '../../core/services/firestore_service.dart';
import '../location/location_service.dart';

enum PublishState { idle, loading, success, locationError, error }

class PublishNotifier extends Notifier<PublishState> {
  @override
  PublishState build() => PublishState.idle;

  Future<void> publish({
    required String title,
    required String description,
    required String zone,
    required String category,
    required String subcategory,
    required String contactPhone,
    required int expiresInHours,
  }) async {
    state = PublishState.loading;
    try {
      final geoPoint = await LocationService.instance.currentGeoFirePoint();

      final now = DateTime.now();
      final freight = Freight(
        id: const Uuid().v4(),
        title: title,
        description: description,
        geoPoint: geoPoint.geopoint,
        geohash: geoPoint.geohash,
        zone: zone,
        category: category,
        subcategory: subcategory,
        status: 'available',
        contactPhone: contactPhone,
        createdAt: now,
        expiresAt: now.add(Duration(hours: expiresInHours)),
      );

      await ref.read(firestoreServiceProvider).publishFreight(freight);
      state = PublishState.success;
    } catch (e, st) {
      log('publishFreight error: $e', stackTrace: st, name: 'PublishNotifier');
      state = PublishState.error;
    }
  }

  void reset() => state = PublishState.idle;
}

final publishFreightProvider =
    NotifierProvider<PublishNotifier, PublishState>(PublishNotifier.new);
