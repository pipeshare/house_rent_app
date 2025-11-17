import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:house_rent_app/core/constants.dart';
import 'package:house_rent_app/core/routes/route_generator.dart';
import 'package:house_rent_app/core/services/navigation_service.dart';
import 'package:house_rent_app/services/auth_gate.dart';
import 'package:house_rent_app/services/firebase_manual.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    log('🚀 Starting Firebase initialization...');

    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );

    await Firebase.initializeApp(
      options: FirebaseManualConfig.androidOptions,
    );
    log('✅ Firebase initialized success!');

    // await DatabaseSeeder.seedInitialData();

    runApp(MyApp());
  } catch (e, stack) {
    log('❌ Firebase initialization failed: $e');
    log('📋 Stack trace: $stack');

    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  final NavigationService _navigationService = NavigationService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Rent App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthGate(),
      navigatorKey: _navigationService.navigatorKey,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
