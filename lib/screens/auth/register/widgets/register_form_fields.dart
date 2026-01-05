import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/auth/login/widgets/login_form_fields.dart';
import '../utils/register_validators.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;

  const NameField({
    super.key,
    required this.controller,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: const Icon(Icons.person_outline),
        suffixIcon: ValidationIcon(isValid: isValid),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: RegisterValidators.validateName,
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;

  const EmailField({
    super.key,
    required this.controller,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: ValidationIcon(isValid: isValid),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: RegisterValidators.validateEmail,
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool isValid;
  final VoidCallback onToggleObscure;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.isValid,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValidationIcon(isValid: isValid),
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: RegisterValidators.validatePassword,
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  final bool isValid;

  const PasswordRequirements({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password must contain:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          PasswordRequirement(
            text: 'At least 6 characters',
            isMet: isValid,
          ),
        ],
      ),
    );
  }
}

class PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordRequirement({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

Color _getBorderColor(bool isValid) {
  return isValid ? Colors.green : Colors.grey;
}
