import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:teamawesomesozeith/utils/version_utils.dart';

class AppUpdateInfo {
  final String minimumVersion;
  final bool isError;

  const AppUpdateInfo({
    required this.minimumVersion,
    required this.isError,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      minimumVersion: json['minimumVersion']?.toString() ?? '',
      isError: json['isError'] == true,
    );
  }
}

enum AppUpdateStatus { upToDate, forceUpdate, maintenance }

class AppUpdateCheckResult {
  final AppUpdateStatus status;
  final String currentVersion;
  final String? minimumVersion;

  const AppUpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.minimumVersion,
  });
}

class AppUpdateService {
  static Future<AppUpdateInfo?> fetchUpdateInfo() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${Environment.baseUrl}/api/updateapp'),
      );
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return AppUpdateInfo.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<AppUpdateCheckResult> evaluateUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final info = await fetchUpdateInfo();
    if (info == null) {
      return AppUpdateCheckResult(
        status: AppUpdateStatus.upToDate,
        currentVersion: currentVersion,
      );
    }

    if (info.isError) {
      return AppUpdateCheckResult(
        status: AppUpdateStatus.maintenance,
        currentVersion: currentVersion,
        minimumVersion: info.minimumVersion,
      );
    }

    if (info.minimumVersion.isNotEmpty &&
        VersionUtils.isBelowMinimum(currentVersion, info.minimumVersion)) {
      return AppUpdateCheckResult(
        status: AppUpdateStatus.forceUpdate,
        currentVersion: currentVersion,
        minimumVersion: info.minimumVersion,
      );
    }

    return AppUpdateCheckResult(
      status: AppUpdateStatus.upToDate,
      currentVersion: currentVersion,
      minimumVersion: info.minimumVersion,
    );
  }
}
