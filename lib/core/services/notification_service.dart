import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/low_stock_utils.dart';
import '../../features/overdue/data/repositories/overdue_repository_impl.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';

const _overdueTask = 'tubigtrack_overdue_check';
const _deliveryTask = 'tubigtrack_delivery_reminder';
const _inventoryTask = 'tubigtrack_inventory_check';

const overdueNotificationId = 1001;
const deliveryNotificationId = 1002;
const inventoryNotificationId = 1003;
const lowStockNotificationBaseId = 1010;

@pragma('vm:entry-point')
void notificationCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.runBackgroundTask(task);
    return true;
  });
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Function(String? payload)? onNotificationTap;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    await Workmanager().initialize(notificationCallbackDispatcher);
    await _registerDailyTasks();
  }

  static Future<void> _registerDailyTasks() async {
    await Workmanager().registerPeriodicTask(
      _overdueTask,
      _overdueTask,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(8, 0),
    );
    await Workmanager().registerPeriodicTask(
      _deliveryTask,
      _deliveryTask,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(7, 0),
    );
    await Workmanager().registerPeriodicTask(
      _inventoryTask,
      _inventoryTask,
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil(8, 30),
    );
  }

  static Duration _delayUntil(int hour, int minute) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }

  static Future<void> runBackgroundTask(String task) async {
    final db = AppDatabase();
    try {
      switch (task) {
        case _overdueTask:
          await _showOverdueNotification(db);
        case _deliveryTask:
          await _showDeliveryReminder(db);
        case _inventoryTask:
          await _showLowInventoryNotification(db);
      }
    } finally {
      await db.close();
    }
  }

  static Future<void> checkAllNow() async {
    final db = AppDatabase();
    try {
      await _showOverdueNotification(db);
      await _showDeliveryReminder(db);
      await _showLowInventoryNotification(db);
    } finally {
      await db.close();
    }
  }

  static Future<void> _showOverdueNotification(AppDatabase db) async {
    final repo = OverdueRepositoryImpl(db);
    final accounts = await repo.getAccounts();
    if (accounts.isEmpty) return;

    final String title;
    final String body;
    if (accounts.length == 1) {
      final a = accounts.first;
      title = '⚠️ Overdue Payment';
      body =
          '${a.customerName}\nBalance: ₱${a.balance.toStringAsFixed(2)}\n${a.daysOverdue} days overdue';
    } else {
      title = '⚠️ ${accounts.length} Overdue Customers';
      body = accounts
          .take(3)
          .map((a) => '${a.customerName} - ₱${a.balance.toStringAsFixed(0)}')
          .join('\n');
    }

    await _show(
      id: overdueNotificationId,
      title: title,
      body: body,
      payload: '/overdue',
    );
  }

  static Future<void> _showDeliveryReminder(AppDatabase db) async {
    final deliveries = await db.deliveriesDao.getTodayActiveDeliveries();
    if (deliveries.isEmpty) return;

    final customers = await db.customersDao.getAll();
    final nameMap = {for (final c in customers) c.id: c.name};

    final String title;
    final String body;
    if (deliveries.length == 1) {
      final d = deliveries.first;
      title = '🚚 Deliveries Today';
      body =
          '${nameMap[d.customerId] ?? 'Customer'}\n${d.quantity} Bottles\n${d.deliveryTime ?? 'No time set'}';
    } else {
      title = '🚚 ${deliveries.length} Deliveries Scheduled Today';
      body = deliveries
          .take(3)
          .map((d) =>
              '${nameMap[d.customerId] ?? 'Customer'} - ${d.quantity} btl')
          .join('\n');
    }

    await _show(
      id: deliveryNotificationId,
      title: title,
      body: body,
      payload: '/deliveries',
    );
  }

  static Future<void> _showLowInventoryNotification(AppDatabase db) async {
    final settingsRepo = SettingsRepositoryImpl(db);
    final inventoryRepo = InventoryRepositoryImpl(db);
    final settings = await settingsRepo.getSettings();
    final summary = await inventoryRepo.getSummary();
    final lowItems = LowStockUtils.check(summary, settings);

    if (lowItems.isEmpty) return;

    for (var i = 0; i < lowItems.length; i++) {
      final item = lowItems[i];
      await _show(
        id: lowStockNotificationBaseId + i,
        title: '⚠️ Low Stock Alert',
        body:
            '${item.label} Remaining: ${item.remaining}\nConsider purchasing additional stock.',
        payload: '/inventory',
      );
    }
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'tubigtrack_alerts',
      'TubigTrack Alerts',
      channelDescription: 'Business alerts and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _plugin.show(id, title, body, details, payload: payload);
  }
}
