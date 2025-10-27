import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.stat,
    required this.statLabel,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String stat;
  final String statLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 6))
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.92))),
          const Spacer(),
          Row(
            children: [
              Text(stat,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22)),
              const SizedBox(width: 4),
              Text(statLabel, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
