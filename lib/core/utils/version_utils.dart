/// Semantic version helpers for update comparison.
class VersionUtils {
  VersionUtils._();

  /// Strips leading "v" and whitespace. e.g. "v1.2.0" → "1.2.0"
  static String normalize(String version) {
    var v = version.trim();
    if (v.startsWith('v') || v.startsWith('V')) {
      v = v.substring(1);
    }
    return v;
  }

  /// Parses "1.2.0" into [1, 2, 0]. Non-numeric suffixes are ignored.
  static List<int> parseParts(String version) {
    final normalized = normalize(version);
    return normalized.split('.').map((part) {
      final digits = RegExp(r'^\d+').stringMatch(part);
      return int.tryParse(digits ?? '0') ?? 0;
    }).toList();
  }

  /// Returns positive if [latest] > [current], negative if less, 0 if equal.
  static int compare(String latest, String current) {
    final a = parseParts(latest);
    final b = parseParts(current);
    final maxLen = a.length > b.length ? a.length : b.length;

    for (var i = 0; i < maxLen; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  static bool isNewer(String latest, String current) =>
      compare(latest, current) > 0;

  static bool isSame(String a, String b) => compare(a, b) == 0;
}
