// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copilot_messages_dao.dart';

// ignore_for_file: type=lint
mixin _$CopilotMessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CopilotMessagesTableTable get copilotMessagesTable =>
      attachedDatabase.copilotMessagesTable;
  CopilotMessagesDaoManager get managers => CopilotMessagesDaoManager(this);
}

class CopilotMessagesDaoManager {
  final _$CopilotMessagesDaoMixin _db;
  CopilotMessagesDaoManager(this._db);
  $$CopilotMessagesTableTableTableManager get copilotMessagesTable =>
      $$CopilotMessagesTableTableTableManager(
        _db.attachedDatabase,
        _db.copilotMessagesTable,
      );
}
