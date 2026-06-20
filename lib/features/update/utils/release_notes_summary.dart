/// Builds a short preview of release notes for collapsed update history cards.
class ReleaseNotesSummary {
  ReleaseNotesSummary._();

  static const int defaultPreviewCount = 3;

  static List<String> cleanLines(List<String> notes) {
    return notes.map(_cleanLine).where((line) => line.isNotEmpty).toList();
  }

  static ({List<String> previewLines, int remainingCount}) summarize(
    List<String> notes, {
    int previewCount = defaultPreviewCount,
  }) {
    final cleaned = cleanLines(notes);
    if (cleaned.isEmpty) {
      return (previewLines: const [], remainingCount: 0);
    }
    if (cleaned.length <= previewCount) {
      return (previewLines: cleaned, remainingCount: 0);
    }
    return (
      previewLines: cleaned.take(previewCount).toList(),
      remainingCount: cleaned.length - previewCount,
    );
  }

  static String _cleanLine(String note) {
    var line = note.trim();
    line = line.replaceFirst(RegExp(r'^#+\s*'), '');
    line = line.replaceFirst(RegExp(r'^[-*]\s*'), '');
    line = line.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    line = line.replaceAll('**', '').replaceAll('*', '').trim();
    return line;
  }
}
