import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasAccount;

  @override
  void initState() {
    super.initState();
    _checkAccount();
  }

  Future<void> _checkAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccount =
        prefs.getString('email') != null && prefs.getString('password') != null;
    setState(() {
      _hasAccount = hasAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAccount == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasAccount! ? const SignInScreen() : const SignUpScreen();
  }
}
