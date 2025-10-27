import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:house_rent_app/core/routes/routes.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _setupAuthListener();
  }

  void _checkAuthState() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 Initial auth check - User: ${user?.email}');
    _currentUser = user;
    _isLoading = false;
    if (mounted) setState(() {});
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('🎯 Auth state changed - User: ${user?.email}');
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        // Navigate using named routes when auth state changes
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, RouteNames.index);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, RouteNames.login);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🔄 AuthWrapper building - isLoading: $_isLoading, user: ${_currentUser?.email}');

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Show empty container - navigation will happen via authStateChanges listener
    return const SizedBox.shrink();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Checking authentication...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
