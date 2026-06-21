import '../../../../core/database/app_database.dart';
import '../../domain/entities/copilot_intent.dart';

/// Abstract interface every query handler must implement.
///
/// To add a new business domain (e.g. Supplier Payables):
///   1. Create `class SupplierPayablesHandler implements BusinessQueryHandler`
///   2. Add new [CopilotIntent] values for the domain
///   3. Add keyword patterns to [CopilotIntentDetector]
///   4. Call `registry.register(SupplierPayablesHandler())` in [RuleBasedAiProvider]
abstract class BusinessQueryHandler {
  /// Returns true if this handler can respond to [intent].
  bool supports(CopilotIntent intent);

  /// Executes the query and returns a formatted answer string.
  Future<String> handle(CopilotIntent intent, String question, AppDatabase db);
}
