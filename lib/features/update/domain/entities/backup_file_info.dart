class BackupFileInfo {
  final String path;
  final String fileName;
  final DateTime modifiedAt;
  final bool isPreUpdate;

  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.modifiedAt,
    this.isPreUpdate = false,
  });
}
