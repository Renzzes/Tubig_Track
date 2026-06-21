import '../../../../core/database/app_database.dart';
import '../../domain/entities/copilot_intent.dart';
import '../../domain/query/business_query_handler.dart';

/// Holds all registered [BusinessQueryHandler]s and dispatches intents to them.
///
/// Handlers are checked in registration order; the first one that
/// [BusinessQueryHandler.supports] the intent wins.
class QueryHandlerRegistry {
  final List<BusinessQueryHandler> _handlers = [];

  /// Register a handler. Built-in handler is registered first by convention.
  void register(BusinessQueryHandler handler) => _handlers.add(handler);

  /// Dispatches [intent] to the first matching handler.
  /// Returns a safe error string when no handler claims the intent.
  Future<String> execute(
    CopilotIntent intent,
    String question,
    AppDatabase db,
  ) async {
    for (final h in _handlers) {
      if (h.supports(intent)) {
        return h.handle(intent, question, db);
      }
    }
    return "I don't support that business query yet.\n\n"
        'Try asking about:\n'
        '• Savings & Profit\n'
        '• Customers & Deliveries\n'
        '• Inventory & Bottles\n'
        '• Payments & Deposits\n'
        '• Business Health Check';
  }
}
