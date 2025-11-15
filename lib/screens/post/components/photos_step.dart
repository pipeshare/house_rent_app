// Extracted Photos Step
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/photo_thumbnail.dart';
import 'package:house_rent_app/screens/post/components/step_title.dart';

import 'add_photo_button.dart';
import 'hint.dart';

class PhotosStep extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const PhotosStep({super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
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
          StepTitle(title: 'Add photos', theme: theme),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < photos.length; i++)
                PhotoThumbnail(
                  photoPath: photos[i],
                  onRemove: () => onRemove(i),
                ),
              AddPhotoButton(onTap: onAdd),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${photos.length} photo(s) selected',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Hint(text: 'Add at least 3 clear photos for best results.'),
        ],
      ),
    );
  }
}