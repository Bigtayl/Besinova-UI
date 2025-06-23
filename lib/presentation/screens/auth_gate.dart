import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/storage_service.dart';
import '../../presentation/providers/user_provider.dart';

/// Authentication gate that now uses a more robust redirection logic.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the first frame is built before navigating.
    // This is a robust way to handle async redirection after initialization.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    try {
      await StorageService.init();
      final bool isSessionActive = await StorageService.isSessionActive();

      if (!mounted) return;

      if (isSessionActive) {
        // Session is active, we MUST load user data before proceeding.
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();

        // Navigate to home and remove all previous routes (Splash, AuthGate).
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // No active session, navigate to sign-in.
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (e) {
      // If any error occurs (e.g., storage fails), default to the sign-in screen.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the redirection logic is running.
    return const Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
