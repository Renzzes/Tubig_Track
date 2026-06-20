import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';

class InventorySettingsScreen extends ConsumerStatefulWidget {
  const InventorySettingsScreen({super.key});

  @override
  ConsumerState<InventorySettingsScreen> createState() =>
      _InventorySettingsScreenState();
}

class _InventorySettingsScreenState
    extends ConsumerState<InventorySettingsScreen> {
  final _bottlesCtrl = TextEditingController();
  final _gallonsCtrl = TextEditingController();
  final _capsCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _bottlesCtrl.dispose();
    _gallonsCtrl.dispose();
    _capsCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  void _load(AppSettings s) {
    if (_loaded) return;
    _bottlesCtrl.text = '${s.minBottles}';
    _gallonsCtrl.text = '${s.minGallons}';
    _capsCtrl.text = '${s.minCaps}';
    _waterCtrl.text = '${s.minWaterStocks}';
    _loaded = true;
  }

  Future<void> _save(AppSettings current) async {
    final settings = current.copyWith(
      minBottles: int.parse(_bottlesCtrl.text),
      minGallons: int.parse(_gallonsCtrl.text),
      minCaps: int.parse(_capsCtrl.text),
      minWaterStocks: int.parse(_waterCtrl.text),
      lowInventoryThreshold: int.parse(_bottlesCtrl.text),
    );
    await ref.read(settingsRepositoryProvider).updateSettings(settings);
    ref.invalidate(appSettingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Settings')),
      body: settingsAsync.when(
        data: (settings) {
          _load(settings);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Low Stock Thresholds',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Notifications and dashboard warnings appear when stock falls at or below these levels.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              _ThresholdField(label: 'Minimum Bottles', controller: _bottlesCtrl),
              _ThresholdField(label: 'Minimum Gallons', controller: _gallonsCtrl),
              _ThresholdField(label: 'Minimum Caps', controller: _capsCtrl),
              _ThresholdField(
                label: 'Minimum Water Stocks',
                controller: _waterCtrl,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(settings),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Save Settings'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ThresholdField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ThresholdField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.inventory_2_outlined),
        ),
      ),
    );
  }
}
