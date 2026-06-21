import '../../../../core/database/app_database.dart';
import '../../domain/entities/copilot_intent.dart';
import '../../domain/entities/copilot_message.dart';
import '../../domain/repositories/copilot_repository.dart';
import '../ai/rule_based_ai_provider.dart';
import '../intent/copilot_intent_detector.dart';

class CopilotRepositoryImpl implements CopilotRepository {
  final AppDatabase _db;
  final RuleBasedAiProvider _provider;
  final CopilotIntentDetector _detector;

  CopilotRepositoryImpl(this._db)
      : _provider = RuleBasedAiProvider(),
        _detector = CopilotIntentDetector();

  @override
  Future<CopilotMessage> ask(String question) async {
    final answer = await _provider.answer(question, _db);
    final intent = _detector.detect(question);
    final now = DateTime.now().millisecondsSinceEpoch;

    final id = await _db.copilotMessagesDao.insertMessage(
      CopilotMessagesTableCompanion.insert(
        question: question,
        answer: answer,
        intent: intent.name,
        createdAt: now,
      ),
    );

    return CopilotMessage(
      id: id,
      question: question,
      answer: answer,
      intent: intent,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  @override
  Stream<List<CopilotMessage>> watchHistory() {
    return _db.copilotMessagesDao.watchAll().map(
      (rows) => rows
          .map((row) => CopilotMessage(
                id: row.id,
                question: row.question,
                answer: row.answer,
                intent: _intentFromName(row.intent),
                createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
              ))
          .toList(),
    );
  }

  @override
  Future<void> clearHistory() async {
    await _db.copilotMessagesDao.deleteAllMessages();
  }

  CopilotIntent _intentFromName(String name) {
    return CopilotIntent.values.firstWhere(
      (i) => i.name == name,
      orElse: () => CopilotIntent.unknown,
    );
  }
}
