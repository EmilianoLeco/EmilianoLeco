import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/argentina_zones.dart';
import 'publish_freight_controller.dart';

class PublishFreightScreen extends ConsumerStatefulWidget {
  const PublishFreightScreen({super.key});

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
        Navigator.pop(context);
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
            content: Text('Error al publicar. Revisá tu conexión e intentá de nuevo.'),
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
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresá el título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción *'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresá la descripción' : null,
              ),
              const SizedBox(height: 16),
              const Text('Zona del flete',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              // Province selector
              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: const InputDecoration(labelText: 'Provincia / Región'),
                items: argentinaZones.keys
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedProvince = v!;
                  _selectedBarrio = null;
                }),
              ),
              const SizedBox(height: 12),
              // Barrio selector
              DropdownButtonFormField<String>(
                value: _selectedBarrio,
                decoration: const InputDecoration(labelText: 'Barrio / Localidad *'),
                items: barrios
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBarrio = v),
                validator: (v) => v == null ? 'Seleccioná un barrio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Teléfono de contacto *'),
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
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
