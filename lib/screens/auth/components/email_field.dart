import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/auth/login/widgets/login_form_fields.dart';

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
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return 'Please enter a valid email';
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
