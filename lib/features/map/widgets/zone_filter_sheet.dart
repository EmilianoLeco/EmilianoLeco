import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/argentina_zones.dart';
import '../map_controller.dart';

class ZoneFilterSheet extends ConsumerStatefulWidget {
  const ZoneFilterSheet({super.key});

  @override
  ConsumerState<ZoneFilterSheet> createState() => _ZoneFilterSheetState();
}

class _ZoneFilterSheetState extends ConsumerState<ZoneFilterSheet> {
  String _selectedProvince = argentinaZones.keys.first;

  @override
  Widget build(BuildContext context) {
    final currentZone = ref.watch(zoneFilterProvider);
    final barrios = argentinaZones[_selectedProvince] ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Filtrar por zona',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (currentZone != null)
                  TextButton(
                    onPressed: () {
                      ref.read(zoneFilterProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar filtro'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Province chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: argentinaZones.keys.map((province) {
                final selected = province == _selectedProvince;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(province),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedProvince = province),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Barrio list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: barrios.length,
              itemBuilder: (context, i) {
                final barrio = barrios[i];
                final isActive = currentZone == barrio;
                return ListTile(
                  title: Text(barrio),
                  trailing: isActive
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  selected: isActive,
                  onTap: () {
                    ref.read(zoneFilterProvider.notifier).state =
                        isActive ? null : barrio;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
