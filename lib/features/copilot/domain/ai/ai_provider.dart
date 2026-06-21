import '../../../../core/database/app_database.dart';

/// Abstract interface for AI providers.
/// RuleBasedAiProvider is the current implementation.
/// Future slot: LocalLlmProvider (Qwen 2.5 1.5B, Gemma 3 1B, Phi-3 Mini).
abstract class AiProvider {
  Future<String> answer(String question, AppDatabase db);
}
