import '../entities/update_channel.dart';
import '../entities/update_history_entry.dart';
import '../entities/update_info.dart';

abstract class UpdateRepository {
  Future<UpdateInfo?> fetchLatestUpdate(UpdateChannel channel);
  Future<void> saveLastCheckTime(DateTime time);
  Future<DateTime?> getLastCheckTime();
  Future<UpdateChannel> getUpdateChannel();
  Future<void> setUpdateChannel(UpdateChannel channel);
  Future<List<UpdateHistoryEntry>> getUpdateHistory();
  Future<void> addUpdateHistoryEntry(UpdateHistoryEntry entry);
  Future<int?> getRecordedBuild();
  Future<void> setRecordedBuild(int build);
  Future<void> savePendingReleaseNotes(List<String> notes);
  Future<List<String>> getPendingReleaseNotes();
  Future<void> clearPendingReleaseNotes();
}
