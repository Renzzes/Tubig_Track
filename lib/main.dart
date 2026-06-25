import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/services/data_storage_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_PH', null);
  await DataStorageService.instance.ensureFolderStructure();
  await NotificationService.initialize();
  runApp(
    const ProviderScope(
      child: TubigTrackApp(),
    ),
  );
}
