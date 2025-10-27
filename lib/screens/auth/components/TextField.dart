import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool showValidationIcon;
  final bool isValid;
  final VoidCallback? onToggleObscureText;
  final double borderRadius;
  final bool enabled;

  const Textfield({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.showValidationIcon = false,
    this.isValid = false,
    this.onToggleObscureText,
    this.borderRadius = 5.0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: _buildSuffixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: _getBorderColor()),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffixIcon != null) return suffixIcon;

    if (onToggleObscureText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showValidationIcon) _buildValidationIcon(),
          IconButton(
            onPressed: onToggleObscureText,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    if (showValidationIcon) return _buildValidationIcon();

    return null;
  }

  Widget _buildValidationIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isValid
          ? Icon(Icons.check_circle,
              color: Colors.green, size: 20, key: UniqueKey())
          : const SizedBox(width: 20),
    );
  }

  Color _getBorderColor() {
    if (!showValidationIcon) return Colors.grey.shade400;
    return isValid ? Colors.green : Colors.orange;
  }
}
