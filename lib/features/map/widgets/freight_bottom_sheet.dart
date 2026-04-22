import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../map_controller.dart';

class FreightBottomSheet extends ConsumerWidget {
  const FreightBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freight = ref.watch(selectedFreightProvider);
    if (freight == null) return const SizedBox.shrink();

    final statusColor = AppColors.forStatus(freight.status);
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    freight.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Chip(
                  label: Text(
                    freight.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(freight.description),
            const Divider(height: 24),
            _InfoRow(icon: Icons.location_on, text: freight.zone),
            _InfoRow(icon: Icons.phone, text: freight.contactPhone),
            _InfoRow(
              icon: Icons.access_time,
              text: 'Vence: ${fmt.format(freight.expiresAt)}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Contactar'),
                onPressed: () {
                  // TODO v2: launch phone dialler via url_launcher
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
