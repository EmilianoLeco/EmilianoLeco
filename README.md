# FreteMap

Android app para localizar fletes en tiempo real por zona, construida con Flutter + Firebase + Google Maps.

## Stack

| Capa | Tecnología |
|------|-----------|
| UI / app | Flutter (Dart) |
| Mapas | Google Maps Flutter |
| Geo-queries | geoflutterfire_plus |
| Base de datos | Firebase Firestore |
| Estado | Riverpod |
| Localización | geolocator + permission_handler |

## Funcionalidades v1

- **Mapa en tiempo real** — markers coloreados por estado (verde = disponible, naranja = asignado, gris = completado)
- **Publicar un flete** — formulario con título, descripción, zona, teléfono y tiempo de expiración
- **Filtro por radio** — 5 / 10 / 25 km desde la ubicación actual
- **Bottom sheet de detalle** — tap en un marker muestra título, descripción, zona, teléfono y vencimiento

## Estructura del proyecto

```
lib/
├── main.dart                           # Bootstrap: Firebase init + ProviderScope
├── app.dart                            # MaterialApp + tema
├── core/
│   ├── constants/app_colors.dart       # Colores por estado de flete
│   ├── models/freight.dart             # Modelo Freight + serialización Firestore
│   └── services/firestore_service.dart # Geo-query stream + CRUD
└── features/
    ├── map/
    │   ├── map_screen.dart             # Pantalla principal con GoogleMap
    │   ├── map_controller.dart         # Providers: radius, status, nearbyFreight, selected
    │   └── widgets/
    │       ├── freight_bottom_sheet.dart
    │       └── radius_filter_dropdown.dart
    ├── freight/
    │   ├── publish_freight_screen.dart
    │   └── publish_freight_controller.dart
    └── location/
        └── location_service.dart       # GPS -> GeoFirePoint
```

## Setup

### 1. Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Agregar una app Android con package name `com.fretemap.app`
3. Descargar `google-services.json` y copiarlo a `android/app/google-services.json`
4. Habilitar **Cloud Firestore** en modo test (luego aplicar las reglas de seguridad de abajo)

### 2. Google Maps

1. Habilitar la API **Maps SDK for Android** en [Google Cloud Console](https://console.cloud.google.com)
2. Crear una API key y reemplazar `YOUR_GOOGLE_MAPS_API_KEY_HERE` en `android/app/build.gradle`:
   ```groovy
   manifestPlaceholders += [googleMapsApiKey: "TU_CLAVE_AQUI"]
   ```

### 3. Correr la app

```bash
flutter pub get
flutter run
```

## Firestore — Modelo de datos

Colección: `freights`

```json
{
  "title": "Mudanza zona norte",
  "description": "Muebles de 2 ambientes",
  "location": {
    "geopoint": "<GeoPoint lat/lng>",
    "geohash": "6g..."
  },
  "zone": "Palermo",
  "status": "available",
  "contactPhone": "1123456789",
  "createdAt": "<Timestamp>",
  "expiresAt": "<Timestamp>"
}
```

## Firestore — Reglas de seguridad

Aplicar en Firebase Console > Firestore > Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /freights/{freightId} {
      allow read: true;
      allow create: if request.resource.data.keys().hasAll([
        'title', 'description', 'location', 'zone',
        'status', 'contactPhone', 'createdAt', 'expiresAt'
      ]) && request.resource.data.status == 'available';
      allow update: if request.resource.data.diff(resource.data)
                         .affectedKeys().hasOnly(['status']);
      allow delete: if false;
    }
  }
}
```

## Firestore — Índice compuesto (para v2)

Para mover el filtro de estado al servidor, crear en Firebase Console > Firestore > Indexes:

| Campo | Orden |
|-------|-------|
| `location.geohash` | Ascending |
| `status` | Ascending |

## Escalabilidad — hooks ya incluidos

| Feature futuro | Qué ya está preparado |
|---|---|
| Autenticación | `ProviderScope` con soporte de overrides en `main.dart` |
| Notificaciones push | Permisos `FOREGROUND_SERVICE_LOCATION` en Manifest |
| Tracking de entrega | `positionStream()` stub en `LocationService` |
| Filtro server-side | Índice definido; cambiar `.map()` por `.where()` en `FirestoreService` |
| iOS | Sin código iOS-específico; agregar carpeta `ios/` y `GoogleService-Info.plist` |
