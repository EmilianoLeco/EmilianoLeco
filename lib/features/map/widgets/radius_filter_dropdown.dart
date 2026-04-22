import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../map_controller.dart';

class RadiusFilterDropdown extends ConsumerWidget {
  const RadiusFilterDropdown({super.key});

  static const _options = [5.0, 10.0, 25.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(radiusProvider);
    return DropdownButton<double>(
      value: selected,
      dropdownColor: Colors.white,
      items: _options
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text('${r.toInt()} km'),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(radiusProvider.notifier).state = v;
      },
    );
  }
}
