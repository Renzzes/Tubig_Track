class UpdateInfo {
  final String version;
  final int build;
  final String apkUrl;
  final List<String> releaseNotes;
  final bool mandatory;

  const UpdateInfo({
    required this.version,
    required this.build,
    required this.apkUrl,
    required this.releaseNotes,
    this.mandatory = false,
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

  bool isNewerThan({required int currentBuild}) => build > currentBuild;
}
