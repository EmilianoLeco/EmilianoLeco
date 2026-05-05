import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fretemap/core/models/freight.dart';

void main() {
  group('Freight.toFirestore', () {
    final freight = Freight(
      id: 'test-id',
      title: 'Mudanza zona norte',
      description: 'Muebles de 2 ambientes',
      geoPoint: const GeoPoint(-34.6037, -58.3816),
      geohash: '69y7pd',
      zone: 'Palermo',
      status: 'available',
      contactPhone: '1123456789',
      createdAt: DateTime(2024, 1, 1),
      expiresAt: DateTime(2024, 1, 2),
    );

    test('serializes location with geopoint and geohash keys', () {
      final map = freight.toFirestore();
      final loc = map['location'] as Map<String, dynamic>;
      expect(loc.containsKey('geopoint'), isTrue);
      expect(loc.containsKey('geohash'), isTrue);
      expect(loc['geohash'], equals('69y7pd'));
    });

    test('status defaults to available on creation', () {
      expect(freight.status, equals('available'));
    });

    test('copyWith only changes status', () {
      final updated = freight.copyWith(status: 'assigned');
      expect(updated.status, equals('assigned'));
      expect(updated.title, equals(freight.title));
      expect(updated.id, equals(freight.id));
    });

    test('all required fields are present in serialized map', () {
      final map = freight.toFirestore();
      for (final key in [
        'title', 'description', 'location', 'zone',
        'status', 'contactPhone', 'createdAt', 'expiresAt',
      ]) {
        expect(map.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });
  });
}
