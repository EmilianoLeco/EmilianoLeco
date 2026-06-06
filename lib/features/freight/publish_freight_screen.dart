import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _zoneCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _expiresHours = 24;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _zoneCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(publishFreightProvider.notifier).publish(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          zone: _zoneCtrl.text.trim(),
          contactPhone: _phoneCtrl.text.trim(),
          expiresInHours: _expiresHours,
        );
  }

  @override
  Widget build(BuildContext context) {
    final publishState = ref.watch(publishFreightProvider);

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
              const SizedBox(height: 12),
              TextFormField(
                controller: _zoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Zona / Barrio *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresá la zona' : null,
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
