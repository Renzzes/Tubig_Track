import '../entities/copilot_message.dart';

abstract class CopilotRepository {
  Future<CopilotMessage> ask(String question);
  Stream<List<CopilotMessage>> watchHistory();
  Future<void> clearHistory();
}
