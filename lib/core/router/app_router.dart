import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../features/splash/presentation/screens/splash_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/customers/presentation/screens/customers_screen.dart';

import '../../features/customers/presentation/screens/customer_form_screen.dart';

import '../../features/customers/presentation/screens/customer_history_screen.dart';

import '../../features/customers/presentation/screens/customer_profile_screen.dart';
import '../../features/customers/presentation/screens/collect_bottles_screen.dart';
import '../../features/customers/presentation/screens/set_initial_bottle_balance_screen.dart';
import '../../features/customers/presentation/screens/adjust_customer_bottle_balance_screen.dart';
import '../../features/customers/presentation/screens/set_customer_owned_bottle_balance_screen.dart';
import '../../features/customers/presentation/screens/adjust_customer_owned_bottle_balance_screen.dart';
import '../../features/customers/presentation/screens/customer_visit_screen.dart';

import '../../features/savings/presentation/screens/savings_detail_screen.dart';
import '../../features/savings/presentation/screens/savings_account_screen.dart';

import '../../features/savings/presentation/screens/savings_history_screen.dart';

import '../../features/transactions/presentation/screens/all_transactions_screen.dart';

import '../../features/deliveries/presentation/screens/deliveries_screen.dart';

import '../../features/deliveries/presentation/screens/add_delivery_screen.dart';

import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/inventory_audit_screen.dart';
import '../../features/inventory/presentation/screens/inventory_audit_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_history_screen.dart';
import '../../features/inventory/presentation/screens/customer_bottle_balances_screen.dart';
import '../../features/inventory/presentation/screens/inventory_tools_screen.dart';
import '../../features/inventory/presentation/screens/business_timeline_screen.dart';

import '../../features/settings/presentation/screens/archive_reset_screen.dart';

import '../../features/update/presentation/screens/disaster_recovery_wizard_screen.dart';
import '../../features/settings/presentation/screens/storage_screen.dart';

import '../../features/settings/presentation/screens/inventory_settings_screen.dart';

import '../../features/suppliers/presentation/screens/suppliers_screen.dart';

import '../../features/suppliers/presentation/screens/supplier_form_screen.dart';

import '../../features/suppliers/presentation/screens/supplier_profile_screen.dart';

import '../../features/savings/presentation/screens/savings_goals_screen.dart';

import '../../features/supply_purchases/presentation/screens/purchase_stock_screen.dart';

import '../../features/supply_purchases/presentation/screens/supply_purchases_history_screen.dart';

import '../../features/supply_purchases/presentation/screens/supplier_summary_screen.dart';

import '../../features/reports/presentation/screens/reports_screen.dart';

import '../../features/payments/presentation/screens/receive_payment_screen.dart';

import '../../features/expenses/presentation/screens/expenses_screen.dart';

import '../../features/dispenser_sales/presentation/screens/dispenser_sales_screen.dart';
import '../../features/walk_in_operations/presentation/screens/walk_in_operations_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';

import '../../features/settings/presentation/screens/factory_reset_screen.dart';

import '../../features/settings/presentation/screens/about_screen.dart';

import '../../features/overdue/presentation/screens/overdue_payments_screen.dart';
import '../../features/dashboard/presentation/screens/unpaid_receivables_screen.dart';
import '../../features/dashboard/presentation/screens/customer_deposits_screen.dart';
import '../../features/dashboard/presentation/screens/business_cash_breakdown_screen.dart';

import '../../features/update/presentation/screens/recovery_center_screen.dart';
import '../../features/update/presentation/screens/read_only_recovery_screen.dart';

import '../../features/update/presentation/screens/update_history_screen.dart';

import '../../features/update/presentation/screens/update_diagnostics_screen.dart';
import '../../features/copilot/presentation/screens/copilot_screen.dart';

import '../../shared/widgets/main_scaffold.dart';
import '../../features/splash/presentation/widgets/startup_background_coordinator.dart';



final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(

    initialLocation: '/splash',

    routes: [

      GoRoute(

        path: '/splash',

        builder: (context, state) => const SplashScreen(),

      ),

      ShellRoute(

        builder: (context, state, child) {

          return StartupBackgroundCoordinator(
            child: MainScaffold(child: child),
          );

        },

        routes: [

          GoRoute(

            path: '/',

            builder: (context, state) => const DashboardScreen(),

          ),

          GoRoute(

            path: '/customers',

            builder: (context, state) => const CustomersScreen(),

          ),

          GoRoute(

            path: '/deliveries',

            builder: (context, state) => const DeliveriesScreen(),

          ),

          GoRoute(

            path: '/inventory',

            builder: (context, state) => const InventoryScreen(),

          ),

          GoRoute(

            path: '/reports',

            builder: (context, state) => const ReportsScreen(),

          ),

        ],

      ),

      GoRoute(

        path: '/customers/add',

        builder: (context, state) => const CustomerFormScreen(),

      ),

      GoRoute(

        path: '/customers/:id/history/deliveries',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerHistoryScreen(
            customerId: id,
            type: CustomerHistoryType.deliveries,
          );
        },

      ),

      GoRoute(

        path: '/customers/:id/history/payments',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerHistoryScreen(
            customerId: id,
            type: CustomerHistoryType.payments,
          );
        },

      ),

      GoRoute(

        path: '/customers/:id/history/bottles',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerHistoryScreen(
            customerId: id,
            type: CustomerHistoryType.bottleTransactions,
          );
        },

      ),

      GoRoute(

        path: '/customers/:id/history/deposits',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerHistoryScreen(
            customerId: id,
            type: CustomerHistoryType.deposits,
          );
        },

      ),

      GoRoute(

        path: '/customers/:id',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return CustomerProfileScreen(customerId: id);

        },

      ),

      GoRoute(

        path: '/customers/:id/edit',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return CustomerFormScreen(customerId: id);

        },

      ),

      GoRoute(
        path: '/customers/:id/visit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerVisitScreen(customerId: id);
        },
      ),

      GoRoute(

        path: '/customers/:id/payment',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return ReceivePaymentScreen(customerId: id);

        },

      ),

      GoRoute(

        path: '/customers/:id/collect-bottles',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return CollectBottlesScreen(customerId: id);

        },

      ),

      GoRoute(

        path: '/customers/:id/initial-balance',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return SetInitialBottleBalanceScreen(customerId: id);

        },

      ),

      GoRoute(

        path: '/customers/:id/adjust-bottles',

        builder: (context, state) {

          final id = state.pathParameters['id']!;

          return AdjustCustomerBottleBalanceScreen(customerId: id);

        },

      ),

      GoRoute(
        path: '/customers/:id/set-customer-owned-balance',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SetCustomerOwnedBottleBalanceScreen(customerId: id);
        },
      ),

      GoRoute(
        path: '/customers/:id/adjust-customer-owned-bottles',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdjustCustomerOwnedBottleBalanceScreen(customerId: id);
        },
      ),

      GoRoute(

        path: '/deliveries/:id/edit',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddDeliveryScreen(deliveryId: id);
        },

      ),

      GoRoute(

        path: '/deliveries/add',

        builder: (context, state) {

          final extra = state.extra as Map<String, dynamic>?;

          final customerId = extra?['customerId'] as String?;

          return AddDeliveryScreen(preselectedCustomerId: customerId);

        },

      ),

      GoRoute(

        path: '/expenses',

        builder: (context, state) => const ExpensesScreen(),

      ),

      GoRoute(

        path: '/dispenser-sales',

        builder: (context, state) => const DispenserSalesScreen(),

      ),

      GoRoute(
        path: '/walk-in-operations',
        builder: (context, state) => const WalkInOperationsScreen(),
      ),

      GoRoute(

        path: '/settings',

        builder: (context, state) => const SettingsScreen(),

      ),

      GoRoute(

        path: '/settings/factory-reset/confirm',

        builder: (context, state) => const FactoryResetConfirmScreen(),

      ),

      GoRoute(

        path: '/settings/factory-reset/complete',

        builder: (context, state) => const FactoryResetCompleteScreen(),

      ),

      GoRoute(

        path: '/settings/inventory',

        builder: (context, state) => const InventorySettingsScreen(),

      ),

      GoRoute(

        path: '/settings/archive-reset',

        builder: (context, state) => const ArchiveResetScreen(),

      ),

      GoRoute(

        path: '/settings/storage',

        builder: (context, state) => const StorageScreen(),

      ),

      GoRoute(

        path: '/about',

        builder: (context, state) => const AboutScreen(),

      ),

      GoRoute(

        path: '/overdue',

        builder: (context, state) => const OverduePaymentsScreen(),

      ),

      GoRoute(

        path: '/receivables/unpaid',

        builder: (context, state) => const UnpaidReceivablesScreen(),

      ),

      GoRoute(

        path: '/deposits/customers',

        builder: (context, state) => const CustomerDepositsScreen(),

      ),

      GoRoute(

        path: '/cash/breakdown',

        builder: (context, state) => const BusinessCashBreakdownScreen(),

      ),

      GoRoute(

        path: '/recovery-center',

        builder: (context, state) => const RecoveryCenterScreen(),

      ),

      GoRoute(

        path: '/disaster-recovery',

        builder: (context, state) => const DisasterRecoveryWizard(),

      ),

      GoRoute(

        path: '/read-only-recovery',

        builder: (context, state) {
          final path = state.extra as String? ?? '';
          return ReadOnlyRecoveryScreen(backupPath: path);
        },

      ),

      GoRoute(

        path: '/update-history',

        builder: (context, state) => const UpdateHistoryScreen(),

      ),

      GoRoute(

        path: '/inventory/history',

        builder: (context, state) => const BusinessTimelineScreen(),

      ),

      GoRoute(

        path: '/inventory/business-timeline',

        builder: (context, state) => const BusinessTimelineScreen(),

      ),

      GoRoute(

        path: '/inventory/customer-balances',

        builder: (context, state) => const CustomerBottleBalancesScreen(),

      ),

      GoRoute(

        path: '/inventory/audit',

        builder: (context, state) => const InventoryAuditScreen(),

      ),

      GoRoute(

        path: '/inventory/audit-history',

        builder: (context, state) => const InventoryAuditHistoryScreen(),

      ),

      GoRoute(

        path: '/inventory/adjustments',

        builder: (context, state) => const InventoryAdjustmentHistoryScreen(),

      ),

      GoRoute(

        path: '/inventory/tools',

        builder: (context, state) => const InventoryToolsScreen(),

      ),

      GoRoute(

        path: '/inventory/purchase-stock',

        builder: (context, state) => const PurchaseStockScreen(),

      ),

      GoRoute(

        path: '/inventory/supply-purchases',

        builder: (context, state) => const SupplyPurchasesHistoryScreen(),

      ),

      GoRoute(

        path: '/inventory/supply-purchases/:id',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PurchaseStockScreen(purchaseId: id);
        },

      ),

      GoRoute(

        path: '/inventory/suppliers',

        builder: (context, state) => const SuppliersScreen(),

      ),

      GoRoute(

        path: '/inventory/suppliers/add',

        builder: (context, state) => const SupplierFormScreen(),

      ),

      GoRoute(

        path: '/inventory/suppliers/:id/edit',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SupplierFormScreen(supplierId: id);
        },

      ),

      GoRoute(

        path: '/inventory/suppliers/:id',

        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SupplierProfileScreen(supplierId: id);
        },

      ),

      GoRoute(

        path: '/reports/supplier-summary',

        builder: (context, state) => const SupplierSummaryScreen(),

      ),

      GoRoute(

        path: '/savings',

        builder: (context, state) => const SavingsDetailScreen(),

      ),

      GoRoute(

        path: '/savings/history',

        builder: (context, state) => const SavingsHistoryScreen(),

      ),

      GoRoute(

        path: '/savings/account',

        builder: (context, state) => const SavingsAccountScreen(),

      ),

      GoRoute(

        path: '/savings/goals',

        builder: (context, state) => const SavingsGoalsScreen(),

      ),

      GoRoute(

        path: '/transactions/all',

        builder: (context, state) => const AllTransactionsScreen(),

      ),

      GoRoute(

        path: '/update-diagnostics',

        builder: (context, state) => const UpdateDiagnosticsScreen(),

      ),

      GoRoute(

        path: '/copilot',

        builder: (context, state) => const CopilotScreen(),

      ),

    ],

  );

});

