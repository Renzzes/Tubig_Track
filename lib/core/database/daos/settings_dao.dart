import 'package:drift/drift.dart';
import '../tables/settings_table.dart';
import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(settingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteValue(String key) async {
    await (delete(settingsTable)..where((t) => t.key.equals(key))).go();
  }

  Future<List<SettingsTableData>> getAll() {
    return select(settingsTable).get();
  }
}
