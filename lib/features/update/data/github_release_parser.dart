import '../../../core/utils/version_utils.dart';
import '../domain/entities/update_info.dart';

class GitHubReleaseParser {
  GitHubReleaseParser._();

  static const apkAssetName = 'app-release.apk';

  static UpdateInfo? parseRelease(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String?;
    if (tagName == null || tagName.isEmpty) return null;

    final version = VersionUtils.normalize(tagName);
    final body = json['body'] as String? ?? '';
    final releaseNotes = _parseReleaseNotes(body);
    final name = json['name'] as String?;

    final assets = json['assets'] as List<dynamic>? ?? [];
    String? apkUrl;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      if (asset['name'] == apkAssetName) {
        apkUrl = asset['browser_download_url'] as String?;
        break;
      }
    }

    if (apkUrl == null || apkUrl.isEmpty) return null;

    DateTime? publishedAt;
    final publishedRaw = json['published_at'] as String?;
    if (publishedRaw != null) {
      publishedAt = DateTime.tryParse(publishedRaw);
    }

    return UpdateInfo(
      version: version,
      build: 0,
      apkUrl: apkUrl,
      releaseNotes: releaseNotes,
      releaseName: name,
      publishedAt: publishedAt,
    );
  }

  static List<String> _parseReleaseNotes(String body) {
    if (body.trim().isEmpty) return const [];

    final lines = body.split('\n');
    final notes = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      var note = trimmed;
      if (note.startsWith('- ') || note.startsWith('* ')) {
        note = note.substring(2).trim();
      } else if (RegExp(r'^[-*]\s*').hasMatch(note)) {
        note = note.replaceFirst(RegExp(r'^[-*]\s*'), '').trim();
      }

      if (note.isNotEmpty) notes.add(note);
    }

    return notes.isEmpty ? [body.trim()] : notes;
  }

  static int countAssets(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>? ?? [];
    return assets.length;
  }

  static String? extractTagName(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String?;
    if (tagName == null) return null;
    return VersionUtils.normalize(tagName);
  }
}
