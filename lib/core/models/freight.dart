import 'package:cloud_firestore/cloud_firestore.dart';

class Freight {
  const Freight({
    required this.id,
    required this.title,
    required this.description,
    required this.geoPoint,
    required this.geohash,
    required this.zone,
    required this.category,
    required this.subcategory,
    required this.status,
    required this.contactPhone,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final GeoPoint geoPoint;
  final String geohash;
  final String zone;
  final String category;    // e.g. 'mudanza'
  final String subcategory; // e.g. 'casa'
  final String status;      // 'available' | 'assigned' | 'completed'
  final String contactPhone;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory Freight.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? _,
  ) {
    final data = snapshot.data()!;
    final loc = data['location'] as Map<String, dynamic>;
    return Freight(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      geoPoint: loc['geopoint'] as GeoPoint,
      geohash: loc['geohash'] as String,
      zone: data['zone'] as String,
      category: data['category'] as String? ?? 'materiales',
      subcategory: data['subcategory'] as String? ?? 'mercaderia_general',
      status: data['status'] as String,
      contactPhone: data['contactPhone'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        // geoflutterfire_plus requires exactly these keys inside 'location'
        'location': {
          'geopoint': geoPoint,
          'geohash': geohash,
        },
        'zone': zone,
        'category': category,
        'subcategory': subcategory,
        'status': status,
        'contactPhone': contactPhone,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': Timestamp.fromDate(expiresAt),
      };

  Freight copyWith({String? status}) => Freight(
        id: id,
        title: title,
        description: description,
        geoPoint: geoPoint,
        geohash: geohash,
        zone: zone,
        category: category,
        subcategory: subcategory,
        status: status ?? this.status,
        contactPhone: contactPhone,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
}
