import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/argentina_zones.dart';
import 'publish_freight_controller.dart';

class PublishFreightScreen extends ConsumerStatefulWidget {
  const PublishFreightScreen({
    super.key,
    required this.category,
    required this.subcategory,
    required this.categoryLabel,
    required this.subtypeLabel,
    required this.categoryColor,
    required this.categoryIcon,
  });

  final String category;
  final String subcategory;
  final String categoryLabel;
  final String subtypeLabel;
  final Color categoryColor;
  final IconData categoryIcon;

  @override
  ConsumerState<PublishFreightScreen> createState() =>
      _PublishFreightScreenState();
}

class _PublishFreightScreenState extends ConsumerState<PublishFreightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _expiresHours = 24;

  String _selectedProvince = argentinaZones.keys.first;
  String? _selectedBarrio;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(publishFreightProvider.notifier).publish(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          zone: _selectedBarrio!,
          category: widget.category,
          subcategory: widget.subcategory,
          contactPhone: _phoneCtrl.text.trim(),
          expiresInHours: _expiresHours,
        );
  }

  @override
  Widget build(BuildContext context) {
    final publishState = ref.watch(publishFreightProvider);
    final barrios = argentinaZones[_selectedProvince] ?? [];

    ref.listen(publishFreightProvider, (_, next) {
      if (next == PublishState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flete publicado exitosamente!')),
        );
        ref.read(publishFreightProvider.notifier).reset();
        // Volver al mapa (pop x3: form → subtype → category)
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      if (next == PublishState.locationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permiso de ubicación denegado. Habilitalo en Ajustes para publicar.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        ref.read(publishFreightProvider.notifier).reset();
      }
      if (next == PublishState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error al publicar. Revisá tu conexión e intentá de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(publishFreightProvider.notifier).reset();
      }
    });

    final isLoading = publishState == PublishState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar flete')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de categoría seleccionada
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.categoryColor.withValues(alpha: 0.1),
                  border: Border.all(
                      color: widget.categoryColor.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.categoryIcon,
                        size: 18, color: widget.categoryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.categoryLabel} · ${widget.subtypeLabel}',
                      style: TextStyle(
                        color: widget.categoryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Mudanza de 3 ambientes en Palermo',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresá el título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  hintText:
                      'Detallá peso, volumen, pisos, si hay ascensor, etc.',
                ),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresá la descripción' : null,
              ),
              const SizedBox(height: 16),
              const Text('Zona de origen',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration:
                    const InputDecoration(labelText: 'Provincia / Región'),
                items: argentinaZones.keys
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedProvince = v!;
                  _selectedBarrio = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBarrio,
                decoration: const InputDecoration(
                    labelText: 'Barrio / Localidad de origen *'),
                items: barrios
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBarrio = v),
                validator: (v) => v == null ? 'Seleccioná el barrio de origen' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono de contacto *',
                  hintText: 'Ej: 1123456789',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v == null || v.length < 10 ? 'Teléfono inválido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _expiresHours,
                decoration: const InputDecoration(labelText: 'Vence en'),
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6 horas')),
                  DropdownMenuItem(value: 12, child: Text('12 horas')),
                  DropdownMenuItem(value: 24, child: Text('24 horas')),
                  DropdownMenuItem(value: 72, child: Text('3 días')),
                ],
                onChanged: (v) => setState(() => _expiresHours = v ?? 24),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.categoryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publicar flete',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
