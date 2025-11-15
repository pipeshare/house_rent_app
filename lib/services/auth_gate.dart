import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:house_rent_app/core/routes/routes.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isInitialCheckComplete = false;
  bool _navigationInProgress = false;
  StreamSubscription<User?>? _authSubscription;

  // Debug mode - set to false in production
  static const bool _debug = false;

  void _log(String message) {
    if (_debug) {
      debugPrint('🔐 AuthGate: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Get initial user state quickly without waiting for full stream
      final initialUser = FirebaseAuth.instance.currentUser;
      _log('Initial auth check - User: ${initialUser?.email ?? "null"}');

      if (mounted) {
        setState(() {
          _currentUser = initialUser;
          _isLoading = false;
          _isInitialCheckComplete = true;
        });
      }

      // Navigate immediately based on initial state
      _safeNavigateBasedOnAuth(initialUser);

      // Set up listener for future changes
      _setupAuthListener();
    } catch (error) {
      _log('Auth initialization error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialCheckComplete = true;
        });
        _safeNavigateToLogin();
      }
    }
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? user) {
        _log('Auth state changed - User: ${user?.email ?? "null"}');

        if (!mounted) return;

        // Only update state if user actually changed
        if (_currentUser?.uid != user?.uid) {
          setState(() => _currentUser = user);
        }

        // Navigate only if initial check is complete
        if (_isInitialCheckComplete) {
          _safeNavigateBasedOnAuth(user);
        }
      },
      onError: (error) {
        _log('Auth listener error: $error');
        if (mounted && _isInitialCheckComplete) {
          _safeNavigateToLogin();
        }
      },
      cancelOnError: false,
    );
  }

  void _safeNavigateBasedOnAuth(User? user) {
    if (_navigationInProgress || !mounted) return;

    _navigationInProgress = true;
    final routeName = user != null ? RouteNames.index : RouteNames.login;
    _log('Starting navigation to: $routeName');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _navigationInProgress = false;
        return;
      }

      _performNavigation(routeName);
    });
  }

  void _safeNavigateToLogin() {
    if (_navigationInProgress || !mounted) return;

    _navigationInProgress = true;
    _log('Starting navigation to login');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _navigationInProgress = false;
        return;
      }

      _performNavigation(RouteNames.login);
    });
  }

  void _performNavigation(String routeName) {
    try {
      Navigator.pushReplacementNamed(context, routeName).then((_) {
        _navigationInProgress = false;
        _log('Navigation completed to: $routeName');
      }).catchError((error) {
        _navigationInProgress = false;
        _log('Navigation error: $error');
        _showErrorFallback();
      });
    } catch (error) {
      _navigationInProgress = false;
      _log('Navigation exception: $error');
      _showErrorFallback();
    }
  }

  void _showErrorFallback() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Error'),
        content: const Text('Unable to navigate to the appropriate screen. Please restart the app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryNavigation();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _forceNavigation();
            },
            child: const Text('Force Navigation'),
          ),
        ],
      ),
    );
  }

  void _retryNavigation() {
    _navigationInProgress = false;
    _safeNavigateBasedOnAuth(_currentUser);
  }

  void _forceNavigation() {
    _navigationInProgress = false;
    // Use a different approach - clear everything and push
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => _buildFallbackScreen(),
      ),
          (route) => false,
    );
  }

  Widget _buildFallbackScreen() {
    // This would be your actual login or main screen
    // For now, return a simple container
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Fallback Screen - Check your routes'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Building - isLoading: $_isLoading, user: ${_currentUser?.email ?? "null"}');

    return _isLoading
        ? const _AuthLoadingScreen()
        : const _AuthRedirectScreen();
  }

  @override
  void dispose() {
    _log('Disposing AuthGate');
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Extracted loading screen as const widget
class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Setting up your experience...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted redirect screen as const widget
class _AuthRedirectScreen extends StatelessWidget {
  const _AuthRedirectScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Redirecting...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative minimal version for maximum performance
class MinimalAuthGate extends StatelessWidget {
  const MinimalAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking initial state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        // Navigate based on auth state
        final user = snapshot.data;
        final routeName = user != null ? RouteNames.index : RouteNames.login;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, routeName);
        });

        return const _AuthRedirectScreen();
      },
    );
  }
}

// Optimized version with immediate navigation
class OptimizedAuthGate extends StatefulWidget {
  const OptimizedAuthGate({super.key});

  @override
  State<OptimizedAuthGate> createState() => _OptimizedAuthGateState();
}

class _OptimizedAuthGateState extends State<OptimizedAuthGate> {
  bool _initialNavigationDone = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _performInitialNavigation();
  }

  void _performInitialNavigation() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final routeName = currentUser != null ? RouteNames.index : RouteNames.login;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, routeName);
      _initialNavigationDone = true;
    });

    // Listen for future auth changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_initialNavigationDone || !mounted) return;

      final newRouteName = user != null ? RouteNames.index : RouteNames.login;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Only navigate if route changed
        if (ModalRoute.of(context)?.settings.name != newRouteName) {
          Navigator.pushReplacementNamed(context, newRouteName);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _AuthLoadingScreen();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Factory for creating the appropriate AuthGate based on needs
class AuthGateFactory {
  static Widget create({bool minimal = false, bool optimized = true}) {
    if (minimal) {
      return const MinimalAuthGate();
    } else if (optimized) {
      return const OptimizedAuthGate();
    } else {
      return const AuthGate();
    }
  }
}