import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:teamawesomesozeith/services/app_update_service.dart';
import 'package:teamawesomesozeith/services/mate_turn_service.dart';
import 'package:teamawesomesozeith/services/match_service.dart';
import 'package:teamawesomesozeith/services/player_service.dart';

enum StartupResult { success, offline, forceUpdate, maintenance }

class StartupOutcome {
  const StartupOutcome({
    required this.result,
    this.currentVersion,
    this.requiredVersion,
  });

  final StartupResult result;
  final String? currentVersion;
  final String? requiredVersion;
}

typedef StartupProgressCallback = void Function(double progress, String label);

class AppStartupService {
  static bool _hasNetworkLink(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Connectivity check, version gate, server ping, and prefetch core APIs.
  static Future<StartupOutcome> bootstrap({
    required StartupProgressCallback onProgress,
  }) async {
    onProgress(0.08, 'Starting…');

    final connectivity = Connectivity();
    List<ConnectivityResult> results;
    try {
      results = await connectivity.checkConnectivity();
    } catch (_) {
      onProgress(1.0, '');
      return const StartupOutcome(result: StartupResult.offline);
    }

    if (!_hasNetworkLink(results)) {
      onProgress(1.0, '');
      return const StartupOutcome(result: StartupResult.offline);
    }

    onProgress(0.22, 'Checking for updates…');

    final updateCheck = await AppUpdateService.evaluateUpdate();
    switch (updateCheck.status) {
      case AppUpdateStatus.maintenance:
        onProgress(1.0, '');
        return StartupOutcome(
          result: StartupResult.maintenance,
          currentVersion: updateCheck.currentVersion,
          requiredVersion: updateCheck.minimumVersion,
        );
      case AppUpdateStatus.forceUpdate:
        onProgress(1.0, '');
        return StartupOutcome(
          result: StartupResult.forceUpdate,
          currentVersion: updateCheck.currentVersion,
          requiredVersion: updateCheck.minimumVersion,
        );
      case AppUpdateStatus.upToDate:
        break;
    }

    onProgress(0.35, 'Checking connection…');

    final serverOk = await _pingServer();
    if (!serverOk) {
      onProgress(1.0, '');
      return const StartupOutcome(result: StartupResult.offline);
    }

    onProgress(0.45, 'Loading players…');
    try {
      await PlayerService.fetchPlayers(forceRefresh: true);
    } catch (e) {
      if (ApiClient.isNetworkError(e)) {
        onProgress(1.0, '');
        return const StartupOutcome(result: StartupResult.offline);
      }
    }

    onProgress(0.72, 'Loading fixtures…');
    await Future.wait([
      MatchService.fetchMatches(forceRefresh: true).catchError((_) {
        MatchService.clearMatches();
      }),
      MateTurnService.fetchAll(forceRefresh: true).catchError((_) {
        MateTurnService.clearCache();
      }),
    ]);

    onProgress(1.0, 'Ready');
    return StartupOutcome(
      result: StartupResult.success,
      currentVersion: updateCheck.currentVersion,
      requiredVersion: updateCheck.minimumVersion,
    );
  }

  static Future<bool> _pingServer() async {
    try {
      await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/updateapp'));
      return true;
    } catch (e) {
      return !ApiClient.isNetworkError(e);
    }
  }
}
