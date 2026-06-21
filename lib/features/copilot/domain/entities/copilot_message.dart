import 'copilot_intent.dart';

class CopilotMessage {
  final int id;
  final String question;
  final String answer;
  final CopilotIntent intent;
  final DateTime createdAt;

  const CopilotMessage({
    required this.id,
    required this.question,
    required this.answer,
    required this.intent,
    required this.createdAt,
  });
}
