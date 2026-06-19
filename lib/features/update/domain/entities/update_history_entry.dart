class UpdateHistoryEntry {
  final String version;
  final int build;
  final DateTime installedAt;
  final List<String> releaseNotes;

  const UpdateHistoryEntry({
    required this.version,
    required this.build,
    required this.installedAt,
    this.releaseNotes = const [],
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'build': build,
        'installedAt': installedAt.toIso8601String(),
        'releaseNotes': releaseNotes,
      };

  factory UpdateHistoryEntry.fromJson(Map<String, dynamic> json) {
    return UpdateHistoryEntry(
      version: json['version'] as String,
      build: json['build'] as int,
      installedAt: DateTime.parse(json['installedAt'] as String),
      releaseNotes: (json['releaseNotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
