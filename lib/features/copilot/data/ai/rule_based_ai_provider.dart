import '../../../../core/database/app_database.dart';
import '../../domain/ai/ai_provider.dart';
import '../../domain/entities/copilot_intent.dart';
import '../intent/copilot_intent_detector.dart';
import '../query/copilot_query_service.dart';
import '../query/query_handler_registry.dart';

/// Rule-based AI provider using keyword intent detection + a handler registry.
///
/// Implements [AiProvider] so a future [LocalLlmProvider] can replace it.
///
/// To add a new business domain, register an additional [BusinessQueryHandler]:
///   `_registry.register(SupplierPayablesHandler())`
class RuleBasedAiProvider implements AiProvider {
  final CopilotIntentDetector _detector;
  final QueryHandlerRegistry _registry;

  RuleBasedAiProvider()
      : _detector = CopilotIntentDetector(),
        _registry = QueryHandlerRegistry() {
    // Register the built-in handler.
    // Future modules append their own handlers here.
    _registry.register(CopilotQueryService());
  }

  @override
  Future<String> answer(String question, AppDatabase db) async {
    final intent = _detector.detect(question);

    if (intent == CopilotIntent.unknown) {
      return "I couldn't understand that question yet.\n\n"
          'Try asking about:\n'
          '• Savings & Profit\n'
          '• Customers & Deliveries\n'
          '• Inventory & Bottles\n'
          '• Payments & Deposits\n'
          '• Business Health Check\n\n'
          'Example: "How much savings do I have?" or "Business health check"';
    }

    return _registry.execute(intent, question, db);
  }
}
