import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:teamawesomesozeith/pages/batting_order_page.dart';
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
    return MaterialApp(
      title: 'Team Awesome Sozeith',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
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

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() => _connectionStatus = results);
  }

  bool get isConnected =>
      !_connectionStatus.contains(ConnectivityResult.none) &&
      _connectionStatus.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? const MainPage()
        : NoInternetScreen(onRetry: _checkConnectivity);
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
        body: _pages[_selectedIndex],
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
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
