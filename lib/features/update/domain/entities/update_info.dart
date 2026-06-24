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

  /// True only when remote [version] is strictly greater than [currentVersion].
  /// Equal versions (e.g. 1.6.3 vs 1.6.3) never qualify as an update.
  bool isNewerThan({
    required String currentVersion,
    required int currentBuild,
  }) {
    return VersionUtils.isNewer(version, currentVersion);
  }
}
