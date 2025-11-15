// lib/routes/route_generator.dart
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/routes/routes.dart';
import 'package:house_rent_app/screens/auth/login_screen.dart';
import 'package:house_rent_app/screens/auth/register_screen.dart';
import 'package:house_rent_app/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:house_rent_app/screens/main.dart';
import 'package:house_rent_app/screens/property/property_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteNames.index:
        return MaterialPageRoute(builder: (_) => const AdvancedMainScreen());

      case RouteNames.propertyDetails:
        return MaterialPageRoute(builder: (_)=> const PropertyDetailsScreen());

      // case RouteNames.editProfile:
      //   if (args is EditProfileArguments) {
      //     return MaterialPageRoute(
      //       builder: (_) => EditProfileScreen(user: args.user),
      //     );
      //   }
      //   return _errorRoute();

      // case RouteNames.settings:
      //   return MaterialPageRoute(builder: (_) => const SettingsScreen());

      // case RouteNames.notifications:
      //   return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found!'),
        ),
      );
    });
  }
}
