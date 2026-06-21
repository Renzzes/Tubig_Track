import 'package:drift/drift.dart';
import '../tables/copilot_messages_table.dart';
import '../app_database.dart';

part 'copilot_messages_dao.g.dart';

@DriftAccessor(tables: [CopilotMessagesTable])
class CopilotMessagesDao extends DatabaseAccessor<AppDatabase>
    with _$CopilotMessagesDaoMixin {
  CopilotMessagesDao(super.db);

  Stream<List<CopilotMessagesTableData>> watchAll() {
    return (select(copilotMessagesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<CopilotMessagesTableData>> getAll() {
    return (select(copilotMessagesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<int> insertMessage(CopilotMessagesTableCompanion companion) {
    return into(copilotMessagesTable).insert(companion);
  }

  Future<int> deleteAllMessages() {
    return delete(copilotMessagesTable).go();
  }
}
