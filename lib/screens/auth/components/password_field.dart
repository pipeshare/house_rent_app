import 'package:flutter/material.dart';

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
            _ValidationIcon(isValid: isValid),
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
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}

// Helper function outside widget tree
Color _getBorderColor(bool isValid) {
  return isValid ? Colors.green : Colors.grey;
}

class _ValidationIcon extends StatelessWidget {
  final bool isValid;

  const _ValidationIcon({required this.isValid});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isValid
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : const SizedBox(width: 20),
    );
  }
}
