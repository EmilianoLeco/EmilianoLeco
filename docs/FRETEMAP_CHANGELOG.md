# FreteMap — Changelog & Roadmap MVP

**App:** FreteMap — Localizador de fletes en tiempo real por zona  
**Stack:** Flutter 3.44 · Firebase Firestore · Google Maps · Riverpod  
**Paquete:** `com.fretemap.app`  
**Repositorio:** github.com/EmilianoLeco/EmilianoLeco  
**Última actualización:** Junio 2026

---

## Versión actual: v0.3.1-alpha

---

## Historial de versiones

### v0.1.0-alpha — Scaffold inicial
**Fecha:** Junio 2026  
**Commit:** `b1c1fc9`

Primera versión funcional de la app. Base completa del proyecto construida desde cero.

**Lo que se construyó:**

- Estructura de proyecto Flutter con arquitectura feature-first
- Modelo de datos `Freight`: título, descripción, ubicación (geopoint + geohash), zona, estado, teléfono, fechas
- Mapa de Google Maps centrado en Buenos Aires con marcadores de colores según estado:
  - Verde → disponible · Naranja → asignado · Celeste → completado
- Stream en tiempo real desde Firestore usando `geoflutterfire_plus` con consultas geográficas por radio
- Formulario para publicar un flete con validaciones
- Filtro de radio (5 / 10 / 25 km) en el AppBar
- Permisos de ubicación (GPS) manejados en runtime
- API key de Google Maps inyectada via `manifestPlaceholders` (nunca hardcodeada)
- Reglas de Firestore básicas para v1 sin autenticación

**Problemas resueltos:**

- Migración del sistema de plugins de Gradle al declarativo (requerido por Flutter 3.44)
- Incompatibilidad AGP 8.11.1 + Kotlin 2.2.20 + compileSdk 36
- Error de tipo Dart: `geoflutterfire_plus` retorna `Stream<List<DocumentSnapshot<T>>>`, no `Stream<List<T>>`
- Conflicto kotlin-stdlib 2.3.x vs compilador Kotlin 2.0.0 (resuelto con plugin externo)

---

### v0.2.0-alpha — Zonas de Argentina + fallback de ubicación
**Fecha:** Junio 2026  
**Commit:** `0016445`

**Cambios:**

- **Fallback de ubicación a Buenos Aires:** si GPS no está disponible o permiso es denegado, el mapa centra en CABA (-34.6037, -58.3816) en lugar de mostrar pantalla en blanco
- **Filtro de zona por provincia/barrio:** botón en AppBar abre bottom sheet con chips de provincia y lista de barrios; chip flotante sobre el mapa indica filtro activo
- **Formulario mejorado:** campo "Zona" reemplazado por doble dropdown Provincia → Barrio para garantizar consistencia con el filtro del mapa
- **Filtrado cliente-side por zona** en el stream de Firestore (sin índice compuesto adicional)
- **API key de Maps leída desde `local.properties`** — la clave real nunca se commitea
- **Reglas de Firestore:** `allow read, write: if true` para v1 sin auth (desplegadas vía Firebase Console)

**Archivos clave:**

| Archivo | Cambio |
|---|---|
| `lib/core/constants/argentina_zones.dart` | Nuevo — 10 provincias/regiones con sus barrios |
| `lib/features/location/location_service.dart` | Fallback a BA, retorno no-nullable |
| `lib/features/map/map_controller.dart` | `zoneFilterProvider` agregado |
| `lib/features/map/map_screen.dart` | Botón de filtro + chip activo sobre el mapa |
| `lib/features/map/widgets/zone_filter_sheet.dart` | Nuevo — bottom sheet de selección de zona |
| `lib/features/freight/publish_freight_screen.dart` | Dropdown provincia/barrio |
| `lib/core/services/firestore_service.dart` | Parámetro `zoneFilter` cliente-side |
| `android/app/build.gradle` | Lee API key desde `local.properties` |
| `firestore.rules` | Reglas abiertas para v1 |

---

### v0.3.0-alpha — UX básica + conectividad + contacto

**Fecha:** Junio 2026  
**Commit:** `1253a12`

**Cambios:**

- **Onboarding de 2 pasos** (se muestra solo al primer inicio):
  - Paso 1: Bienvenida con logo y tagline
  - Paso 2: Selección de rol — "Soy fletero" o "Necesito un flete" con tarjetas animadas
  - Rol guardado en `SharedPreferences`; reinicio va directo al mapa
- **Banner de sin conexión** usando `connectivity_plus`: avisa cuando no hay internet y ofrece "Reintentar"
- **Pull-to-refresh** en el mapa: deslizar hacia abajo invalida el stream de fletes y la ubicación
- **Pantalla de error** con botón "Reintentar" cuando Firestore no responde
- **Botón Contactar** funcional en el bottom sheet de cada flete:
  - WhatsApp: abre con mensaje pre-cargado "Hola, vi tu flete en FreteMap. ¿Está disponible?"
  - Llamar: abre el marcador telefónico del dispositivo
- **Versión bump:** `1.0.0+1` → `0.3.0+3`

**Paquetes agregados:**

| Paquete | Versión | Uso |
|---|---|---|
| `shared_preferences` | ^2.3.2 | Persistir rol de usuario y estado de onboarding |
| `connectivity_plus` | ^6.1.0 | Detectar estado de red en tiempo real |
| `url_launcher` | ^6.3.1 | Abrir WhatsApp y marcador telefónico |

**Archivos nuevos:**

| Archivo | Descripción |
|---|---|
| `lib/core/services/preferences_service.dart` | Wrapper de SharedPreferences |
| `lib/core/providers/connectivity_provider.dart` | `StreamProvider<bool>` de conectividad |
| `lib/features/onboarding/onboarding_screen.dart` | Pantalla de onboarding con PageView |

---

### v0.3.1-alpha — Selección de tipo de flete

**Fecha:** Junio 2026  
**Commit:** `a280a00`

Rediseño del flujo de publicación: en lugar de un formulario directo, el usuario primero clasifica qué tipo de flete necesita. Esto permite mostrar advertencias específicas por tipo de carga y preparar el terreno para filtros por categoría.

**Flujo nuevo:**

```
Mapa
  └─ "Publicar flete"
       └─ CategorySelectionScreen (grid 2×2)
            └─ SubtypeSelectionScreen (lista con notas)
                 └─ PublishFreightScreen (formulario con badge de categoría)
```

**Categorías y subcategorías implementadas:**

| Categoría | ID | Subcategorías |
|---|---|---|
| Mudanza | `mudanza` | Casa/dpto · Oficina/comercio · Depósito/galpón |
| Traslado de materiales | `materiales` | Alimentos · Bodega/vinos · Antigüedades · Construcción · Electrodomésticos · Muebles · Textil · Químicos · Farmacéuticos · Mercadería general |
| Traslado de maquinaria | `maquinaria` | Agrícola · Industrial · Herramientas · Vehículos |
| Cargas especiales | `especiales` | Carga viva · Encomiendas · Residuos controlados · Otro |

**Notas de advertencia por subtipo** (ejemplos):
- *Productos químicos* → "Carga peligrosa — requiere habilitación RUTA"
- *Carga viva* → "Requiere habilitación SENASA"
- *Alimentos y bebidas* → "Indicá si requiere cadena de frío"
- *Maquinaria agrícola* → "Indicá si puede circular de noche o requiere escolta"

**Cambios en el modelo `Freight`:**

```dart
// Campos nuevos (con fallback en fromFirestore para documentos viejos)
final String category;    // e.g. 'mudanza'
final String subcategory; // e.g. 'casa'
```

**Archivos nuevos:**

| Archivo | Descripción |
|---|---|
| `lib/core/constants/freight_categories.dart` | Datos de categorías/subcategorías con notas |
| `lib/features/freight/category_selection_screen.dart` | Grid de categorías + lista de subtipos |

**Archivos modificados:**

| Archivo | Cambio |
|---|---|
| `lib/core/models/freight.dart` | Campos `category` y `subcategory` |
| `lib/features/freight/publish_freight_controller.dart` | Parámetros `category` y `subcategory` |
| `lib/features/freight/publish_freight_screen.dart` | Recibe categoría, muestra badge de color |
| `lib/features/map/map_screen.dart` | FAB navega a `CategorySelectionScreen` |
| `lib/features/map/widgets/freight_bottom_sheet.dart` | Badge de categoría en detalle del flete |
| `test/freight_model_test.dart` | Actualizado con nuevos campos requeridos |

---

## Arquitectura actual (v0.3.1)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart              # Paleta de colores
│   │   ├── argentina_zones.dart         # 10 provincias/regiones con barrios
│   │   └── freight_categories.dart      # Categorías y subcategorías de flete
│   ├── models/
│   │   └── freight.dart                 # Modelo + Firestore serialization
│   ├── providers/
│   │   └── connectivity_provider.dart   # StreamProvider<bool> de red
│   └── services/
│       ├── firestore_service.dart        # Geo-queries y CRUD
│       └── preferences_service.dart     # SharedPreferences wrapper
├── features/
│   ├── freight/
│   │   ├── category_selection_screen.dart    # Paso 1 y 2 del flujo de publicación
│   │   ├── publish_freight_controller.dart   # Notifier de publicación
│   │   └── publish_freight_screen.dart       # Formulario (paso 3)
│   ├── location/
│   │   └── location_service.dart             # GPS + fallback BA
│   ├── map/
│   │   ├── map_controller.dart               # Providers Riverpod
│   │   ├── map_screen.dart                   # Pantalla principal
│   │   └── widgets/
│   │       ├── freight_bottom_sheet.dart     # Detalle con contacto y categoría
│   │       ├── radius_filter_dropdown.dart   # Filtro de radio
│   │       └── zone_filter_sheet.dart        # Filtro de zona
│   └── onboarding/
│       └── onboarding_screen.dart            # Bienvenida + selección de rol
└── main.dart / app.dart
```

**Providers Riverpod activos:**

| Provider | Tipo | Descripción |
|---|---|---|
| `userLocationProvider` | `FutureProvider<GeoFirePoint>` | GPS con fallback a BA |
| `radiusProvider` | `StateProvider<double>` | Radio de búsqueda en km |
| `statusFilterProvider` | `StateProvider<String?>` | Filtro por estado del flete |
| `zoneFilterProvider` | `StateProvider<String?>` | Filtro por barrio |
| `nearbyFreightProvider` | `StreamProvider<List<Freight>>` | Stream geo-filtrado |
| `selectedFreightProvider` | `StateProvider<Freight?>` | Flete seleccionado en mapa |
| `publishFreightProvider` | `NotifierProvider` | Estado del flujo de publicación |
| `connectivityProvider` | `StreamProvider<bool>` | Estado de red |

---

## Limitaciones conocidas (v0.3.1-alpha)

| # | Limitación | Impacto | Solución planificada |
|---|---|---|---|
| 1 | Sin autenticación | Cualquiera puede publicar | v0.4.0 — Firebase Auth SMS |
| 2 | Reglas Firestore abiertas | Sin seguridad en producción | v0.4.0 — Reglas con `request.auth` |
| 3 | Maps en blanco en emulador API 36 | Solo en emulador x86_64 Android 16 | Usar AVD API 33/34 o dispositivo físico |
| 4 | Sin filtro por categoría en el mapa | No se puede buscar solo "Mudanzas" | v0.5.0 — filtro de categoría |
| 5 | Sin paginación en el mapa | Con muchos fletes puede haber lag | v0.6.0 — clustering de marcadores |
| 6 | Sin notificaciones push | El usuario no sabe si llega un flete | v0.5.0 — Firebase Cloud Messaging |
| 7 | Sin foto del flete | Solo texto | v0.6.0 — Firebase Storage |
| 8 | Rol de usuario no afecta la UX aún | Se guardó pero no se usa | v0.4.0 — perfil por rol |

---

## Roadmap MVP — 2 meses

**Objetivo:** App funcional, segura y publicable en Google Play.

---

### ✅ Semana 1–2 · v0.3.x — Estabilización y UX básica — COMPLETADO

- [x] Onboarding de 2 pasos con selección de rol
- [x] Manejo de errores de conectividad con banner y reintentar
- [x] Pull-to-refresh en el mapa
- [x] Botón "Contactar" via WhatsApp y llamada telefónica
- [x] Clasificación de fletes por categoría y subcategoría
- [x] Notas de advertencia por tipo de carga (habilitaciones, cuidados especiales)
- [ ] Probar en dispositivo Android físico con AVD API 33/34

---

### Semana 3–4 · v0.4.0 — Autenticación

**Objetivo:** Saber quién publica cada flete.

- [ ] Firebase Auth con número de teléfono (SMS OTP)
- [ ] Pantalla de login/verificación SMS
- [ ] Guardar nombre y teléfono del usuario en Firestore al registrarse
- [ ] Asociar cada flete al `uid` del usuario que lo publica
- [ ] Actualizar reglas de Firestore: solo el dueño puede editar/borrar su flete
- [ ] "Mis fletes publicados" — lista en perfil del usuario
- [ ] UX diferenciada por rol: fletero ve fletes cerca, remitente va directo a publicar

---

### Semana 5–6 · v0.5.0 — Gestión del flete

**Objetivo:** Cerrar el ciclo publicar → contactar → completar.

- [ ] Filtro por categoría en el mapa (además del radio y zona)
- [ ] El publicador puede cambiar estado: disponible → asignado → completado
- [ ] Fletes expirados se ocultan automáticamente del mapa (basado en `expiresAt`)
- [ ] Pantalla de detalle completo del flete
- [ ] Firebase Cloud Messaging: notificación cuando aparece un flete en tu zona guardada

---

### Semana 7–8 · v0.6.0 — Pulido y notificaciones

**Objetivo:** Retención de usuarios + experiencia lista para producción.

- [ ] Guardar "zona favorita" del usuario para alertas push
- [ ] Clustering de marcadores en el mapa cuando hay muchos fletes juntos
- [ ] Foto del flete (Firebase Storage, imagen opcional)
- [ ] Dark mode
- [ ] Ícono de app definitivo
- [ ] Reglas de Firestore en producción (con rate limiting)

---

### Semana 9 · v1.0.0 — Lanzamiento

**Objetivo:** Publicar en Google Play.

- [ ] Generar keystore de producción y firmado de APK
- [ ] Cuenta de desarrollador en Google Play Console (u$s 25 único pago)
- [ ] Screenshots y descripción para el store
- [ ] Política de privacidad (requerida por Google Play)
- [ ] Release en modo "prueba interna" con usuarios reales
- [ ] Firebase Crashlytics para monitoreo de crashes

---

## Buenas prácticas a mantener

### Seguridad

- API key de Google Maps siempre desde `local.properties` (gitignoreado)
- `google-services.json` en `.gitignore`
- En producción: reglas de Firestore con `request.auth != null`
- Nunca hardcodear claves, UIDs ni tokens en el código

### Código

- Arquitectura feature-first: cada feature tiene su screen, controller y widgets propios
- Riverpod declarativo: `StateProvider`, `StreamProvider`, `NotifierProvider` según el caso
- Filtros cliente-side en v1; migrar a server-side cuando el volumen lo requiera
- Modelo con fallback en `fromFirestore` para no romper documentos viejos al agregar campos

### Android / Build

- AGP 8.11.1 + Kotlin 2.2.20 + compileSdk 36 — no bajar estas versiones
- Kotlin como plugin externo (`org.jetbrains.kotlin.android`) — no usar `builtInKotlin`
- Gradle wrapper: 8.14.1

### Firebase

- Firestore: colección `/freights/{id}` con campo `location: { geopoint, geohash }` requerido por `geoflutterfire_plus`
- Reglas abiertas SOLO en desarrollo; cerrar antes del primer usuario real
- Campos nuevos en el modelo siempre con `?? 'default'` en `fromFirestore` para compatibilidad hacia atrás

### Versionado

- Formato: `MAJOR.MINOR.PATCH-stage` (ej: `0.3.1-alpha`)
- Cada versión tiene su entrada en este documento con commit hash, cambios y archivos afectados
- Actualizar `version:` en `pubspec.yaml` con cada release

---

## Cómo convertir este documento a PDF

### Opción A — VS Code (recomendado)

1. Instalar extensión "Markdown PDF" (autor: yzane)
2. Click derecho sobre este archivo → "Markdown PDF: Export (pdf)"

### Opción B — Chrome

1. Abrir el archivo en GitHub
2. Ctrl+P → Guardar como PDF

---

FreteMap v0.3.1-alpha · Junio 2026
