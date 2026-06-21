import 'package:drift/drift.dart';

class CopilotMessagesTable extends Table {
  @override
  String get tableName => 'copilot_messages';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  TextColumn get intent => text()();
  IntColumn get createdAt => integer()();
}
