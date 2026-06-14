import 'package:flutter/material.dart';
import '../../core/constants/freight_categories.dart';
import 'publish_freight_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Qué necesitás transportar?')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: freightTypes.length,
        itemBuilder: (context, i) => _CategoryCard(type: freightTypes[i]),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.type});
  final FreightType type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubtypeSelectionScreen(type: type),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.08),
          border: Border.all(color: type.color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, size: 36, color: type.color),
            ),
            const SizedBox(height: 12),
            Text(
              type.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              type.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SubtypeSelectionScreen extends StatelessWidget {
  const SubtypeSelectionScreen({super.key, required this.type});
  final FreightType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type.label),
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de categoría
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: type.color.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(type.icon, color: type.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¿Qué tipo de ${type.label.toLowerCase()}?',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de subtipos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: type.subtypes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 20),
              itemBuilder: (context, i) {
                final sub = type.subtypes[i];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  title: Text(sub.label,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: sub.note != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.amber[700]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sub.note!,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  trailing: Icon(Icons.chevron_right,
                      color: type.color),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublishFreightScreen(
                        category: type.id,
                        subcategory: sub.id,
                        categoryLabel: type.label,
                        subtypeLabel: sub.label,
                        categoryColor: type.color,
                        categoryIcon: type.icon,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
