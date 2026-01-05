import 'dart:async';
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/routes/routes.dart';
import 'package:house_rent_app/screens/auth/register/utils/register_handlers.dart';
import 'package:house_rent_app/screens/auth/register/utils/register_validators.dart';
import 'package:house_rent_app/screens/auth/register/widgets/register_buttons.dart';
import 'package:house_rent_app/screens/auth/register/widgets/register_form_fields.dart';
import 'package:house_rent_app/screens/auth/register/widgets/register_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const route = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  bool loading = false;
  bool obscure = true;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isNameValid = false;

  Timer? _nameDebounceTimer;
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
    nameCtrl.addListener(_onNameChanged);
    emailCtrl.addListener(_onEmailChanged);
    passCtrl.addListener(_onPasswordChanged);
  }

  void _cleanupResources() {
    _nameDebounceTimer?.cancel();
    _emailDebounceTimer?.cancel();
    _passwordDebounceTimer?.cancel();
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
  }

  void _onNameChanged() {
    _nameDebounceTimer?.cancel();
    _nameDebounceTimer =
        Timer(const Duration(milliseconds: 300), _validateName);
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

  void _validateName() {
    final isValid = RegisterValidators.isValidName(nameCtrl.text.trim());
    if (_isNameValid != isValid) {
      setState(() => _isNameValid = isValid);
    }
  }

  void _validateEmail() {
    final email = emailCtrl.text.trim();
    final isValid = RegisterValidators.isValidEmail(email);
    if (_isEmailValid != isValid) {
      setState(() => _isEmailValid = isValid);
    }
  }

  void _validatePassword() {
    final isValid = RegisterValidators.isValidPassword(passCtrl.text);
    if (_isPasswordValid != isValid) {
      setState(() => _isPasswordValid = isValid);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final name = nameCtrl.text.trim();

    try {
      setState(() => loading = true);
      await RegisterHandlers.handleRegistration(
        context: context,
        email: email,
        password: pass,
        name: name,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        await RegisterHandlers.handleRegistrationError(context, e);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
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
                  const RegisterHeader(),
                  const SizedBox(height: 32),
                  NameField(
                    controller: nameCtrl,
                    isValid: _isNameValid,
                  ),
                  const SizedBox(height: 16),
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
                  PasswordRequirements(isValid: _isPasswordValid),
                  const SizedBox(height: 24),
                  RegisterButton(
                    loading: loading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 16),
                  LoginRedirect(
                    loading: loading,
                    onPressed: _navigateToLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
