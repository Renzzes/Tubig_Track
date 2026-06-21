import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/customer_sort_option.dart';

const _customerSortPrefKey = 'customer_list_sort_option';

class CustomerSortNotifier extends AsyncNotifier<CustomerSortOption> {
  @override
  Future<CustomerSortOption> build() async {
    final prefs = await SharedPreferences.getInstance();
    return CustomerSortOption.fromStorage(prefs.getString(_customerSortPrefKey));
  }

  Future<void> setSort(CustomerSortOption option) async {
    state = AsyncData(option);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerSortPrefKey, option.name);
  }
}

final customerSortOptionProvider =
    AsyncNotifierProvider<CustomerSortNotifier, CustomerSortOption>(
  CustomerSortNotifier.new,
);
