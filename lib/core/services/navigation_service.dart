// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/routes/routes.dart';
import 'package:house_rent_app/models/user.dart';
import '../routes/route_arguments.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateReplacement(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateAndRemoveUntil(String routeName,
      {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  // Convenience methods for specific routes
  void toHome() => navigateAndRemoveUntil(RouteNames.home);
  void toLogin() => navigateAndRemoveUntil(RouteNames.login);
  void toProfile(String userId, {bool isEditable = false}) =>
      navigateTo(RouteNames.profile,
          arguments: ProfileArguments(userId: userId, isEditable: isEditable));
  void toEditProfile(User user) => navigateTo(RouteNames.editProfile,
      arguments: EditProfileArguments(user: user));
}
