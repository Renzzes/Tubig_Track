import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/features/update/utils/release_notes_summary.dart';

void main() {
  group('ReleaseNotesSummary', () {
    test('summarize returns all lines when count is within preview limit', () {
      final result = ReleaseNotesSummary.summarize([
        'Inventory Management',
        'Supplier Tracking',
      ]);

      expect(result.previewLines, [
        'Inventory Management',
        'Supplier Tracking',
      ]);
      expect(result.remainingCount, 0);
    });

    test('summarize returns preview and remaining count for long lists', () {
      final notes = List.generate(
        15,
        (i) => 'Feature ${i + 1}',
      );

      final result = ReleaseNotesSummary.summarize(notes);

      expect(result.previewLines.length, 3);
      expect(result.previewLines.first, 'Feature 1');
      expect(result.remainingCount, 12);
    });

    test('cleanLines strips markdown bullets and headers', () {
      final cleaned = ReleaseNotesSummary.cleanLines([
        '## Inventory Management',
        '- Supplier Tracking',
        '1. Savings Goals',
        '**Reset UX**',
      ]);

      expect(cleaned, [
        'Inventory Management',
        'Supplier Tracking',
        'Savings Goals',
        'Reset UX',
      ]);
    });
  });
}
