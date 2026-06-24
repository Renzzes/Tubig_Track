import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/customers_provider.dart';
import '../providers/customer_sort_provider.dart';
import '../../domain/entities/customer_sort_option.dart';
import '../widgets/customer_list_tile.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(sortedCustomersProvider);
    final sortAsync = ref.watch(customerSortOptionProvider);
    final currentSort = sortAsync.value ?? CustomerSortOption.nameAsc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, address...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(customerSearchQueryProvider.notifier)
                                    .update('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref
                          .read(customerSearchQueryProvider.notifier)
                          .update(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<CustomerSortOption>(
                  tooltip: 'Sort customers',
                  icon: const Icon(Icons.sort),
                  initialValue: currentSort,
                  onSelected: (option) {
                    ref.read(customerSortOptionProvider.notifier).setSort(option);
                  },
                  itemBuilder: (context) => CustomerSortOption.values
                      .map(
                        (option) => PopupMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              if (option == currentSort)
                                const Icon(Icons.check, size: 18)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(option.label)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    message: 'No customers yet',
                    subMessage: 'Tap + to add your first customer',
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: context.fabListBottomPadding,
                  ),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerListTile(
                      customer: customer,
                      onTap: () => context.push('/customers/${customer.id}/visit'),
                      onEdit: () =>
                          context.push('/customers/${customer.id}/edit'),
                      onDelete: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Delete Customer',
                          message:
                              'Delete ${customer.name}? This will not delete delivery records.',
                          confirmText: 'Delete',
                        );
                        if (confirmed == true && context.mounted) {
                          await ref
                              .read(customerRepositoryProvider)
                              .deleteCustomer(customer.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${customer.name} deleted'),
                              ),
                            );
                          }
                        }
                      },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
