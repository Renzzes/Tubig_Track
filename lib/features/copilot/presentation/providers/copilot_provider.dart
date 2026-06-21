import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/insights/copilot_insights_service.dart';
import '../../data/repositories/copilot_repository_impl.dart';
import '../../domain/entities/copilot_message.dart';
import '../../domain/repositories/copilot_repository.dart';

final copilotRepositoryProvider = Provider<CopilotRepository>((ref) {
  return CopilotRepositoryImpl(ref.watch(databaseProvider));
});

final copilotHistoryProvider = StreamProvider<List<CopilotMessage>>((ref) {
  return ref.watch(copilotRepositoryProvider).watchHistory();
});

/// Proactive insights generated when the Copilot screen opens.
final copilotInsightsProvider = FutureProvider<List<String>>((ref) {
  final db = ref.watch(databaseProvider);
  return CopilotInsightsService(db).generateInsights();
});

class CopilotNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<CopilotMessage?> ask(String question) async {
    state = const AsyncValue.loading();
    try {
      final message = await ref.read(copilotRepositoryProvider).ask(question);
      state = const AsyncValue.data(null);
      return message;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> clearHistory() async {
    await ref.read(copilotRepositoryProvider).clearHistory();
  }
}

final copilotNotifierProvider =
    NotifierProvider<CopilotNotifier, AsyncValue<void>>(CopilotNotifier.new);
