import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/freight_categories.dart';
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
            const SizedBox(height: 6),
            _CategoryBadge(
              category: freight.category,
              subcategory: freight.subcategory,
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _contactWhatsApp(freight.contactPhone),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Llamar'),
                  onPressed: () => _callPhone(freight.contactPhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final number = cleaned.startsWith('54') ? cleaned : '54$cleaned';
    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent('Hola, vi tu flete en FreteMap. ¿Está disponible?')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'\D'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category, required this.subcategory});
  final String category;
  final String subcategory;

  @override
  Widget build(BuildContext context) {
    final type = freightTypeById(category);
    final sub = freightSubtypeById(category, subcategory);
    if (type == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(type.icon, size: 14, color: type.color),
        const SizedBox(width: 4),
        Text(
          sub != null ? '${type.label} · ${sub.label}' : type.label,
          style: TextStyle(
            fontSize: 12,
            color: type.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
