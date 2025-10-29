import 'package:flutter/material.dart';
import 'package:house_rent_app/constants/constants.dart';
import 'package:house_rent_app/models/Professional.dart';

class ProfessionalGridCard extends StatelessWidget {
  final Professional pro;
  final VoidCallback onTap;
  const ProfessionalGridCard({
    super.key,
    required this.pro,
    required this.onTap,
  });

  Widget _badge(String label, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(.12)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pro.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person,
                              size: 30, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pro.name,
                            style: kBodyStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(
                            '${pro.specialty.name[0].toUpperCase()}${pro.specialty.name.substring(1)} • ${pro.company}',
                            style: kCaptionStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14),
                            const SizedBox(width: 6),
                            Text(pro.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.work_outline, size: 14),
                            const SizedBox(width: 6),
                            Text('${pro.yearsExperience}y',
                                style: TextStyle(fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _badge(pro.verified ? 'VERIFIED' : 'UNVERIFIED',
                      bg: pro.verified
                          ? kPrimaryColor.withOpacity(.10)
                          : Colors.white),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // quick call handler placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Call ${pro.phone}')));
                    },
                    icon: const Icon(Icons.call, size: 20),
                    tooltip: 'Call',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
