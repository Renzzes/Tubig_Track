import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/suppliers_provider.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/suppliers/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: suppliersAsync.when(
              data: (all) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = all.where((s) {
                  if (query.isEmpty) return true;
                  return s.name.toLowerCase().contains(query) ||
                      (s.contactPerson?.toLowerCase().contains(query) ?? false) ||
                      (s.mobile?.contains(query) ?? false);
                }).toList();
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No suppliers found',
                    icon: Icons.store_outlined,
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.store, color: AppColors.primary),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        [s.contactPerson, s.mobile]
                            .whereType<String>()
                            .where((v) => v.isNotEmpty)
                            .join(' • '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/inventory/suppliers/${s.id}'),
                    );
                  },
                );
              },
              loading: () => const LoadingOverlay(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
