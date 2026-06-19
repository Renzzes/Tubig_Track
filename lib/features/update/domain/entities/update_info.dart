import '../../../../core/utils/version_utils.dart';

class UpdateInfo {
  final String version;
  final int build;
  final String apkUrl;
  final List<String> releaseNotes;
  final bool mandatory;
  final String? releaseName;
  final DateTime? publishedAt;

  const UpdateInfo({
    required this.version,
    required this.build,
    required this.apkUrl,
    required this.releaseNotes,
    this.mandatory = false,
    this.releaseName,
    this.publishedAt,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String,
      build: json['build'] as int,
      apkUrl: json['apk_url'] as String,
      releaseNotes: (json['release_notes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mandatory: json['mandatory'] as bool? ?? false,
    );
  }

  /// True when remote [version] is newer than [currentVersion].
  /// Falls back to [build] comparison when versions are equal.
  bool isNewerThan({
    required String currentVersion,
    required int currentBuild,
  }) {
    final cmp = VersionUtils.compare(version, currentVersion);
    if (cmp > 0) return true;
    if (cmp < 0) return false;
    if (build > 0 && currentBuild > 0) {
      return build > currentBuild;
    }
    return false;
  }
}
