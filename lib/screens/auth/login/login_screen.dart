import 'dart:async';
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/auth/register/register_screen.dart';
import 'package:house_rent_app/core/routes/route_generator.dart';
import 'package:house_rent_app/core/routes/routes.dart';

// Widgets
import 'widgets/login_header.dart';
import 'widgets/login_form_fields.dart';
import 'widgets/login_buttons.dart';

// Utils
import 'utils/login_validators.dart';
import 'utils/login_handlers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  bool obscure = true;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  Timer? _emailDebounceTimer;
  Timer? _passwordDebounceTimer;

  @override
  void initState() {
    super.initState();
    _setupTextListeners();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _setupTextListeners() {
    emailCtrl.addListener(_onEmailChanged);
    passCtrl.addListener(_onPasswordChanged);
  }

  void _cleanupResources() {
    _emailDebounceTimer?.cancel();
    _passwordDebounceTimer?.cancel();
    emailCtrl.dispose();
    passCtrl.dispose();
  }

  void _onEmailChanged() {
    _emailDebounceTimer?.cancel();
    _emailDebounceTimer =
        Timer(const Duration(milliseconds: 300), _validateEmail);
  }

  void _onPasswordChanged() {
    _passwordDebounceTimer?.cancel();
    _passwordDebounceTimer =
        Timer(const Duration(milliseconds: 300), _validatePassword);
  }

  void _validateEmail() {
    final email = emailCtrl.text.trim();
    final isValid = LoginValidators.isValidEmail(email);
    if (_isEmailValid != isValid) {
      setState(() => _isEmailValid = isValid);
    }
  }

  void _validatePassword() {
    final isValid = passCtrl.text.isNotEmpty;
    if (_isPasswordValid != isValid) {
      setState(() => _isPasswordValid = isValid);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    try {
      setState(() => loading = true);
      await LoginHandlers.handleLogin(
        context: context,
        email: email,
        password: pass,
        onSuccess: () => _navigateToHome(),
      );
    } catch (e) {
      if (mounted) {
        await LoginHandlers.handleLoginError(context, e, email);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      RouteGenerator.generateRoute(
        const RouteSettings(name: RouteNames.index),
      ),
    );
  }

  Future<void> _resetPassword() async {
    await LoginHandlers.handlePasswordReset(
      context: context,
      email: emailCtrl.text.trim(),
    );
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, RegisterScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 32),
                  EmailField(
                    controller: emailCtrl,
                    isValid: _isEmailValid,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: passCtrl,
                    obscure: obscure,
                    isValid: _isPasswordValid,
                    onToggleObscure: () => setState(() => obscure = !obscure),
                  ),
                  const SizedBox(height: 8),
                  ForgotPasswordButton(
                    loading: loading,
                    onPressed: _resetPassword,
                  ),
                  const SizedBox(height: 16),
                  SignInButton(
                    loading: loading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),
                  const OrDivider(),
                  const SizedBox(height: 24),
                  RegisterRedirect(
                    loading: loading,
                    onPressed: _navigateToRegister,
                  ),
                  const SizedBox(height: 24),
                  const TermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
