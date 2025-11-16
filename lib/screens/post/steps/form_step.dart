// Reusable Form Step Layout
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/step_title.dart';

class FormStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const FormStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(title: title, theme: theme),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
