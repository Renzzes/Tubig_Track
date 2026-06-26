import '../../core/database/backup_metadata.dart';
import '../../features/update/domain/repositories/backup_repository.dart';
import 'backup_verification_service.dart';

enum BackupHealthTier {
  excellent,
  migratable,
  legacy,
  readOnlyOnly,
  damaged,
}

class BackupHealthInfo {
  final BackupHealthTier tier;
  final int stars;
  final String label;
  final String subtitle;
  final bool verificationPassed;
  final BackupCompatibilityStatus? compatibilityStatus;

  const BackupHealthInfo({
    required this.tier,
    required this.stars,
    required this.label,
    required this.subtitle,
    required this.verificationPassed,
    this.compatibilityStatus,
  });
}

class BackupHealthService {
  BackupHealthService._();

  static final BackupHealthService instance = BackupHealthService._();

  Future<BackupHealthInfo> evaluate({
    required String backupPath,
    required BackupRepository repository,
  }) async {
    final verification =
        await BackupVerificationService.instance.verify(backupPath);
    if (!verification.passed) {
      return BackupHealthInfo(
        tier: BackupHealthTier.damaged,
        stars: 1,
        label: 'Damaged',
        subtitle: 'Verification Failed',
        verificationPassed: false,
      );
    }

    final compatibility = await repository.checkCompatibility(backupPath);
    switch (compatibility.status) {
      case BackupCompatibilityStatus.compatible:
        return BackupHealthInfo(
          tier: BackupHealthTier.excellent,
          stars: 5,
          label: 'Excellent',
          subtitle: 'Verified · Compatible · Current',
          verificationPassed: true,
          compatibilityStatus: compatibility.status,
        );
      case BackupCompatibilityStatus.migratable:
        return BackupHealthInfo(
          tier: BackupHealthTier.migratable,
          stars: 4,
          label: 'Migratable',
          subtitle: 'Safe to Restore',
          verificationPassed: true,
          compatibilityStatus: compatibility.status,
        );
      case BackupCompatibilityStatus.unknown:
        return BackupHealthInfo(
          tier: BackupHealthTier.legacy,
          stars: 3,
          label: 'Legacy',
          subtitle: 'Migration Required',
          verificationPassed: true,
          compatibilityStatus: compatibility.status,
        );
      case BackupCompatibilityStatus.unsupported:
        return BackupHealthInfo(
          tier: BackupHealthTier.readOnlyOnly,
          stars: 2,
          label: 'Read-Only Only',
          subtitle: compatibility.reason ?? 'Unsupported schema',
          verificationPassed: true,
          compatibilityStatus: compatibility.status,
        );
      case BackupCompatibilityStatus.newerThanApp:
        return BackupHealthInfo(
          tier: BackupHealthTier.readOnlyOnly,
          stars: 2,
          label: 'Read-Only Only',
          subtitle: 'From a newer app version',
          verificationPassed: true,
          compatibilityStatus: compatibility.status,
        );
    }
  }
}
