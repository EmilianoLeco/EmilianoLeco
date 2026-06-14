import 'package:flutter/material.dart';

class FreightSubtype {
  const FreightSubtype({
    required this.id,
    required this.label,
    this.note,
  });

  final String id;
  final String label;
  // Nota visible en el formulario para recordar al usuario algo importante
  final String? note;
}

class FreightType {
  const FreightType({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.subtypes,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final List<FreightSubtype> subtypes;
}

const List<FreightType> freightTypes = [
  FreightType(
    id: 'mudanza',
    label: 'Mudanza',
    description: 'Traslado de hogar, oficina o comercio',
    icon: Icons.home_work,
    color: Color(0xFF4CAF50),
    subtypes: [
      FreightSubtype(id: 'casa', label: 'Casa o departamento'),
      FreightSubtype(id: 'oficina', label: 'Oficina o comercio'),
      FreightSubtype(
        id: 'deposito',
        label: 'Depósito o galpón',
        note: 'Indicá si hay montacargas disponible en destino.',
      ),
    ],
  ),
  FreightType(
    id: 'materiales',
    label: 'Traslado de materiales',
    description: 'Cargas fraccionadas o a granel de todo tipo',
    icon: Icons.inventory_2,
    color: Color(0xFF2196F3),
    subtypes: [
      FreightSubtype(id: 'alimentos', label: 'Alimentos y bebidas',
          note: 'Indicá si requiere cadena de frío.'),
      FreightSubtype(id: 'bodega', label: 'Productos de bodega / Vinos',
          note: 'Indicá si requiere embalaje especial o temperatura controlada.'),
      FreightSubtype(id: 'antiguedades', label: 'Antigüedades y arte',
          note: 'Requiere embalaje especializado y manejo delicado.'),
      FreightSubtype(id: 'construccion', label: 'Materiales de construcción',
          note: 'Indicá peso aproximado y si se necesita grúa o hidrogrúa.'),
      FreightSubtype(id: 'electrodomesticos', label: 'Electrodomésticos'),
      FreightSubtype(id: 'muebles', label: 'Muebles y decoración'),
      FreightSubtype(id: 'textil', label: 'Indumentaria y textil'),
      FreightSubtype(
        id: 'quimicos',
        label: 'Productos químicos',
        note: 'Carga peligrosa — el fletero debe contar con habilitación RUTA.',
      ),
      FreightSubtype(id: 'farmaceutico', label: 'Productos farmacéuticos',
          note: 'Verificá si requiere cadena de frío o documentación especial.'),
      FreightSubtype(id: 'mercaderia_general', label: 'Mercadería general'),
    ],
  ),
  FreightType(
    id: 'maquinaria',
    label: 'Traslado de maquinaria',
    description: 'Equipos industriales, agrícolas o vehículos',
    icon: Icons.precision_manufacturing,
    color: Color(0xFFFF9800),
    subtypes: [
      FreightSubtype(
        id: 'agricola',
        label: 'Maquinaria agrícola',
        note: 'Indicá dimensiones y si puede circular de noche o requiere escolta.',
      ),
      FreightSubtype(
        id: 'industrial',
        label: 'Maquinaria industrial',
        note: 'Indicá peso y si necesitá cama baja o camión jaula.',
      ),
      FreightSubtype(id: 'herramientas', label: 'Herramientas y equipos'),
      FreightSubtype(
        id: 'vehiculos',
        label: 'Vehículos y automotores',
        note: 'Indicá si el vehículo está en marcha o no.',
      ),
    ],
  ),
  FreightType(
    id: 'especiales',
    label: 'Cargas especiales',
    description: 'Animales, encomiendas u otras necesidades',
    icon: Icons.star_outline,
    color: Color(0xFF9C27B0),
    subtypes: [
      FreightSubtype(
        id: 'carga_viva',
        label: 'Carga viva (animales)',
        note: 'El transporte de animales requiere habilitación SENASA.',
      ),
      FreightSubtype(id: 'encomiendas', label: 'Encomiendas y paquetería'),
      FreightSubtype(id: 'residuos', label: 'Residuos controlados',
          note: 'Requiere manifiesto de transporte y habilitación municipal.'),
      FreightSubtype(id: 'otro', label: 'Otro (especificar en descripción)'),
    ],
  ),
];

FreightType? freightTypeById(String id) {
  try {
    return freightTypes.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}

FreightSubtype? freightSubtypeById(String typeId, String subtypeId) {
  return freightTypeById(typeId)
      ?.subtypes
      .where((s) => s.id == subtypeId)
      .firstOrNull;
}
