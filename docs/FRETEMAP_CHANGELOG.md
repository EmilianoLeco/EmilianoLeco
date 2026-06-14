# FreteMap — Changelog & Roadmap MVP

**App:** FreteMap — Localizador de fletes en tiempo real por zona  
**Stack:** Flutter 3.44 · Firebase Firestore · Google Maps · Riverpod  
**Paquete:** `com.fretemap.app`  
**Repositorio:** github.com/EmilianoLeco/EmilianoLeco  
**Fecha del documento:** Junio 2026  

---

## Versión actual: v0.2.0-alpha

---

## Historial de versiones

### v0.1.0-alpha — Scaffold inicial
**Fecha:** Junio 2026

Primera versión funcional de la app. Se construyó la base completa del proyecto desde cero.

**Lo que se construyó:**

- Estructura de proyecto Flutter con arquitectura feature-first
- Modelo de datos `Freight` con campos: título, descripción, ubicación (geopoint + geohash), zona, estado, teléfono, fechas
- Mapa de Google Maps centrado en Buenos Aires con marcadores de colores según estado del flete:
  - Verde → disponible
  - Naranja → asignado
  - Celeste → completado
- Stream en tiempo real desde Firestore usando `geoflutterfire_plus` con consultas geográficas por radio
- Formulario para publicar un flete con validaciones
- Filtro de radio (5 / 10 / 25 km) en el AppBar
- Permisos de ubicación (GPS) manejados en runtime
- API key de Google Maps inyectada via `manifestPlaceholders` (nunca hardcodeada en el código)
- Reglas de Firestore básicas para v1 sin autenticación

**Problemas resueltos durante esta versión:**

- Migración del sistema de plugins de Gradle al declarativo (requerido por Flutter 3.44)
- Incompatibilidad entre AGP 8.11.1 + Kotlin 2.2.20 + compileSdk 36
- Error de tipo Dart: `geoflutterfire_plus` retorna `Stream<List<DocumentSnapshot<T>>>`, no `Stream<List<T>>`
- Conflicto de metadatos entre kotlin-stdlib 2.3.x y compilador Kotlin 2.0.0 (resuelto con plugin externo)

---

### v0.2.0-alpha — Zonas de Argentina + fallback de ubicación
**Fecha:** Junio 2026

**Cambios:**

- **Fallback de ubicación a Buenos Aires:** si el GPS no está disponible o el permiso es denegado, el mapa centra automáticamente en el centro de CABA (-34.6037, -58.3816) en lugar de mostrar pantalla en blanco
- **Filtro de zona por provincia/barrio:** botón en el AppBar abre un bottom sheet con:
  - Chips de provincia/región (CABA, GBA Norte, GBA Sur, GBA Oeste, Córdoba, Rosario, Mendoza, Tucumán, Santa Fe, Salta)
  - Lista de barrios/localidades por provincia seleccionada
  - Chip flotante sobre el mapa indicando el filtro activo, con botón para limpiar
- **Formulario de publicar mejorado:** el campo "Zona" ahora es un doble dropdown Provincia → Barrio (en lugar de texto libre), asegurando consistencia con el filtro del mapa
- **Filtrado cliente-side por zona** agregado al stream de Firestore (sin índice compuesto adicional)
- **API key de Maps movida a `local.properties`:** la clave real nunca se commitea al repositorio
- **Reglas de Firestore simplificadas** a `allow read, write: if true` para v1 sin auth

**Archivos clave modificados:**

| Archivo | Cambio |
|---|---|
| `lib/core/constants/argentina_zones.dart` | Nuevo — datos de zonas |
| `lib/features/location/location_service.dart` | Fallback a BA |
| `lib/features/map/map_controller.dart` | `zoneFilterProvider` |
| `lib/features/map/map_screen.dart` | Botón de filtro + chip activo |
| `lib/features/map/widgets/zone_filter_sheet.dart` | Nuevo — selector de zona |
| `lib/features/freight/publish_freight_screen.dart` | Dropdown provincia/barrio |
| `lib/core/services/firestore_service.dart` | Parámetro `zoneFilter` |
| `android/app/build.gradle` | Lee API key desde `local.properties` |
| `firestore.rules` | Reglas abiertas para v1 |

---

## Arquitectura actual

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Paleta de colores
│   │   └── argentina_zones.dart    # Provincias y barrios
│   ├── models/
│   │   └── freight.dart            # Modelo de datos + Firestore serialization
│   └── services/
│       └── firestore_service.dart  # Geo-queries y CRUD
├── features/
│   ├── freight/
│   │   ├── publish_freight_controller.dart   # Notifier de publicación
│   │   └── publish_freight_screen.dart       # Formulario
│   ├── location/
│   │   └── location_service.dart             # GPS + fallback BA
│   └── map/
│       ├── map_controller.dart               # Providers Riverpod
│       ├── map_screen.dart                   # Pantalla principal
│       └── widgets/
│           ├── freight_bottom_sheet.dart     # Detalle del flete
│           ├── radius_filter_dropdown.dart   # Filtro de radio
│           └── zone_filter_sheet.dart        # Filtro de zona
└── main.dart / app.dart
```

**Providers Riverpod activos:**

| Provider | Tipo | Descripción |
|---|---|---|
| `userLocationProvider` | `FutureProvider<GeoFirePoint>` | Ubicación del usuario (fallback BA) |
| `radiusProvider` | `StateProvider<double>` | Radio de búsqueda en km |
| `statusFilterProvider` | `StateProvider<String?>` | Filtro por estado del flete |
| `zoneFilterProvider` | `StateProvider<String?>` | Filtro por barrio |
| `nearbyFreightProvider` | `StreamProvider<List<Freight>>` | Stream de fletes cercanos |
| `selectedFreightProvider` | `StateProvider<Freight?>` | Flete seleccionado en mapa |
| `publishFreightProvider` | `NotifierProvider` | Estado de publicación |

---

## Limitaciones conocidas (v0.2.0-alpha)

| # | Limitación | Impacto | Solución planificada |
|---|---|---|---|
| 1 | Sin autenticación | Cualquiera puede publicar | v0.4.0 — Firebase Auth |
| 2 | Reglas Firestore abiertas | Sin seguridad en producción | v0.4.0 — Reglas con auth |
| 3 | Maps en blanco en emulador API 36 | Solo en emulador x86_64 Android 16 | Usar AVD API 33/34 o dispositivo físico |
| 4 | Zona solo filtra coincidencia exacta | Si el barrio se escribe diferente, no matchea | Resuelto — ambos usan el mismo dropdown |
| 5 | Sin paginación en el mapa | Con muchos fletes puede haber lag | v0.6.0 — clustering de marcadores |
| 6 | Sin notificaciones push | El usuario no sabe si llega un flete | v0.5.0 — Firebase Cloud Messaging |
| 7 | Sin foto o descripción enriquecida | Flete solo tiene texto | v0.6.0 — Firebase Storage |

---

## Roadmap MVP — 2 meses

**Objetivo:** Tener una app funcional, segura y publicable en Google Play con las funciones mínimas para conectar fleteros con clientes.

---

### Semana 1–2 · v0.3.0 — Estabilización y UX básica

**Objetivo:** App usable en dispositivo real, sin bugs críticos.

- [ ] Probar en dispositivo Android físico (resolver problema de emulador API 36)
- [ ] Pantalla de splash y onboarding de 2 pasos (¿sos fletero o cliente?)
- [ ] Manejo de errores visible al usuario (sin Firestore, sin GPS, sin internet)
- [ ] Pull-to-refresh en el mapa
- [ ] Validar que el flete publicado aparece en el mapa en tiempo real

---

### Semana 3–4 · v0.4.0 — Autenticación

**Objetivo:** Saber quién publica cada flete.

- [ ] Firebase Auth con número de teléfono (SMS OTP) — común en apps de logística
- [ ] Pantalla de login/verificación SMS
- [ ] Guardar nombre y teléfono del usuario en Firestore al registrarse
- [ ] Asociar cada flete al `uid` del usuario que lo publica
- [ ] Actualizar reglas de Firestore: solo el dueño puede editar/borrar su flete
- [ ] "Mis fletes publicados" — lista en perfil

---

### Semana 5–6 · v0.5.0 — Gestión del flete

**Objetivo:** Cerrar el ciclo de un flete (publicar → contactar → asignar → completar).

- [ ] Botón "Me interesa" en el bottom sheet del flete (abre WhatsApp con número del publicador)
- [ ] El publicador puede cambiar el estado del flete: disponible → asignado → completado
- [ ] Fletes expirados se ocultan automáticamente del mapa (basado en `expiresAt`)
- [ ] Página de detalle completo del flete (expandir desde el bottom sheet)

---

### Semana 7–8 · v0.6.0 — Notificaciones y pulido

**Objetivo:** Retención de usuarios y experiencia lista para producción.

- [ ] Firebase Cloud Messaging (FCM): notificación cuando aparece un flete nuevo en tu zona guardada
- [ ] Guardar "zona favorita" del usuario para recibir alertas
- [ ] Clustering de marcadores en el mapa cuando hay muchos fletes juntos
- [ ] Dark mode
- [ ] Icono de app y nombre definitivo
- [ ] Reglas de Firestore en producción (con rate limiting)

---

### Semana 9 · v1.0.0 — Lanzamiento

**Objetivo:** Publicar en Google Play.

- [ ] Generar keystore de producción y firmado de APK
- [ ] Crear cuenta de desarrollador en Google Play Console (u$s 25 único pago)
- [ ] Screenshots y descripción para el store
- [ ] Política de privacidad (requerida por Google Play)
- [ ] Release en modo "prueba interna" con usuarios reales
- [ ] Monitoreo de crashes con Firebase Crashlytics

---

## Buenas prácticas a mantener

### Seguridad
- La API key de Google Maps se lee siempre desde `local.properties` (gitignoreado), nunca se commitea
- `google-services.json` está en `.gitignore`
- En producción, las reglas de Firestore deben validar `request.auth != null`

### Código
- Arquitectura feature-first: cada pantalla tiene su propio controller, screen y widgets
- State management con Riverpod: providers declarativos, sin setState innecesario
- Filtros cliente-side en v1 para evitar índices compuestos; migrar a server-side cuando el volumen lo requiera

### Android / Build
- AGP 8.11.1 + Kotlin 2.2.20 + compileSdk 36 — no bajar estas versiones
- Kotlin como plugin externo (`org.jetbrains.kotlin.android`) — no usar `builtInKotlin`
- Gradle wrapper: 8.14.1

### Firebase
- Firestore: estructura flat (`/freights/{id}`) con campo `location: { geopoint, geohash }` — requerido por geoflutterfire_plus
- Reglas abiertas SOLO en desarrollo; cerrar antes del primer usuario real

---

## Cómo convertir este documento a PDF

**Opción A — VS Code (recomendado):**
1. Instalar extensión "Markdown PDF" (autor: yzane)
2. Click derecho sobre este archivo → "Markdown PDF: Export (pdf)"

**Opción B — Chrome:**
1. Abrir el archivo `.md` en un visor web (como GitHub)
2. Ctrl+P → Guardar como PDF

---

*Documento generado automáticamente · FreteMap v0.2.0-alpha · Junio 2026*
