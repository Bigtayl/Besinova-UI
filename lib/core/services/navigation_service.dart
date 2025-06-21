import 'package:flutter/material.dart';

/// Service for handling navigation throughout the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the navigator state
  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) =>
      navigator!.pushNamed<T>(routeName, arguments: arguments);

  /// Navigate to a named route and replace current route
  static Future<T?> navigateToReplacement<T>(String routeName,
          {Object? arguments}) =>
      navigator!.pushReplacementNamed<T, void>(routeName, arguments: arguments);

  /// Navigate to a named route and clear all previous routes
  static Future<T?> navigateToAndClear<T>(String routeName,
          {Object? arguments}) =>
      navigator!.pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );

  /// Go back to previous route
  static void goBack<T>([T? result]) => navigator!.pop<T>(result);

  /// Check if can go back
  static bool canGoBack() => navigator!.canPop();

  /// Get current route name
  static String? getCurrentRoute() {
    String? currentRoute;
    navigator!.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute;
  }
}
