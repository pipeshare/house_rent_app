import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: ListTile(
        leading: Icon(icon, color: kTitleColor),
        title: Text(title,
            style: const TextStyle(
              color: kTitleColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            )),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(color: kBodyTextColor)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: kBodyTextColor),
        onTap: () {},
      ),
    );
  }
}
