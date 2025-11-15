
// Extracted Photo Thumbnail
import 'dart:io';

import 'package:flutter/material.dart';

class PhotoThumbnail extends StatelessWidget {
  final String photoPath;
  final VoidCallback onRemove;

  const PhotoThumbnail({super.key,
    required this.photoPath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(photoPath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            onPressed: onRemove,
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}