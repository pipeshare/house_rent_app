
// Extracted Add Photo Button
import 'package:flutter/material.dart';

class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddPhotoButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, size: 30),
            SizedBox(height: 4),
            Text('Add', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}