import 'update_info.dart';

enum UpdateFetchError {
  none,
  network,
  api,
  parse,
  noApkAsset,
}

class UpdateFetchResult {
  final UpdateInfo? updateInfo;
  final int? statusCode;
  final String apiUrl;
  final String? latestVersion;
  final String? downloadUrl;
  final int assetCount;
  final UpdateFetchError error;
  final String? errorDetail;
  final DateTime fetchedAt;

  UpdateFetchResult({
    this.updateInfo,
    this.statusCode,
    required this.apiUrl,
    this.latestVersion,
    this.downloadUrl,
    this.assetCount = 0,
    this.error = UpdateFetchError.none,
    this.errorDetail,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  bool get isSuccess =>
      error == UpdateFetchError.none && updateInfo != null;

  bool get isNetworkError => error == UpdateFetchError.network;

  bool get isApiError =>
      error == UpdateFetchError.api ||
      error == UpdateFetchError.parse ||
      error == UpdateFetchError.noApkAsset;
}
