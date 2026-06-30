import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/pages/batting_order_page.dart';
import 'package:teamawesomesozeith/pages/mate_turn_page.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:teamawesomesozeith/pages/stats_leaderboard.dart';
import 'pages/home_page.dart';
import 'pages/players_list_page.dart';
import 'pages/settings_page.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(CricketTeamApp(isFirstTime: isFirstTime));
}

class CricketTeamApp extends StatelessWidget {
  final bool isFirstTime;
  const CricketTeamApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0BA37F),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Team Awesome Sozeith',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ).copyWith(
        primaryColor: colorScheme.primary,
      ),
      home: isFirstTime ? const OnboardingPage() : const ConnectivityWrapper(),
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

enum _GateState { initializing, online, offline }

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  static const _offlineDebounce = Duration(seconds: 2);

  _GateState _gateState = _GateState.initializing;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _offlineDebounceTimer;

  @override
  void initState() {
    super.initState();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _runFullCheck();
  }

  @override
  void dispose() {
    _offlineDebounceTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  bool _hasNetworkLink(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  Future<bool> _pingApi() async {
    try {
      await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/updateapp'));
      return true;
    } catch (e) {
      return !ApiClient.isNetworkError(e);
    }
  }

  void _scheduleOffline() {
    _offlineDebounceTimer?.cancel();
    _offlineDebounceTimer = Timer(_offlineDebounce, () {
      if (mounted) setState(() => _gateState = _GateState.offline);
    });
  }

  Future<void> _runFullCheck() async {
    _offlineDebounceTimer?.cancel();
    setState(() => _gateState = _GateState.initializing);

    try {
      final results = await _connectivity.checkConnectivity();

      if (!_hasNetworkLink(results)) {
        if (!mounted) return;
        setState(() => _gateState = _GateState.offline);
        return;
      }

      final apiReachable = await _pingApi();
      if (!mounted) return;

      setState(() => _gateState =
          apiReachable ? _GateState.online : _GateState.offline);
    } catch (_) {
      if (!mounted) return;
      setState(() => _gateState = _GateState.offline);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (!_hasNetworkLink(results)) {
      if (_gateState == _GateState.online) {
        _scheduleOffline();
      } else {
        _offlineDebounceTimer?.cancel();
        if (mounted) setState(() => _gateState = _GateState.offline);
      }
      return;
    }

    _offlineDebounceTimer?.cancel();
    _runFullCheck();
  }

  @override
  Widget build(BuildContext context) {
    switch (_gateState) {
      case _GateState.initializing:
        return const CheckingConnectionScreen();
      case _GateState.online:
        return const MainPage();
      case _GateState.offline:
        return NoInternetScreen(onRetry: _runFullCheck);
    }
  }
}

class CheckingConnectionScreen extends StatelessWidget {
  const CheckingConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Checking connection…',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verifying network and server',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ApiWrapper(child: const HomePage()),
      const PlayersPage(),
      const BattingOrderPage(),
      const MateTurnPage(),
      const StatsLeaderboardPage(),
      const SettingsPage(),
    ];
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // Not on Home → switch to Home
      setState(() => _selectedIndex = 0);
      return false; // cancel the default pop
    }
    // On Home → send app to background
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // iOS doesn't support backgrounding via SystemNavigator
      // so we just pop (which closes the app)
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_cricket), label: 'Batting Order'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_cafe), label: 'Mate'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: 'Stats'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class ApiWrapper extends StatefulWidget {
  final Widget child;
  const ApiWrapper({super.key, required this.child});

  @override
  State<ApiWrapper> createState() => _ApiWrapperState();
}

class _ApiWrapperState extends State<ApiWrapper> {
  bool _apiError = false;

  void _handleApiError() {
    setState(() => _apiError = true);
  }

  void _retryApi() {
    setState(() => _apiError = false);
    // Add logic to retry API calls here
  }

  @override
  Widget build(BuildContext context) {
    return _apiError
        ? ApiErrorScreen(onRetry: _retryApi)
        : _ApiErrorHandler(
            onError: _handleApiError,
            child: widget.child,
          );
  }
}

class _ApiErrorHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onError;

  const _ApiErrorHandler({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ApiErrorNotification>(
      onNotification: (notification) {
        onError();
        return true;
      },
      child: child,
    );
  }
}

class ApiErrorNotification extends Notification {}

Future<void> _openPlayStoreListing(BuildContext context) async {
  final uri = Uri.tryParse(Environment.playstoreUrl);
  if (uri == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid store link')),
      );
    }
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open ${uri.toString()}')),
    );
  }
}

class ApiErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const ApiErrorScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[600]),
              const SizedBox(height: 20),
              Text(
                'API Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Failed to load data from server. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.system_update),
                      label: const Text('Check app update'),
                      onPressed: () => _openPlayStoreListing(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 80, color: Colors.grey[600]),
              const SizedBox(height: 20),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Please check your internet connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.system_update),
                      label: const Text('Check app update'),
                      onPressed: () => _openPlayStoreListing(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
