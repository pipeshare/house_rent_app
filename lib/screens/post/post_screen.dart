import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _pageController = PageController();
  int _current = 0;

  // Cache for post options to prevent recreation
  static const List<_PostOption> _options = [
    _PostOption(label: 'House for Rent', icon: Icons.house_rounded),
    _PostOption(label: 'Apartment for Rent', icon: Icons.apartment_rounded),
    _PostOption(label: 'Short Let / BnB', icon: Icons.night_shelter_rounded),
    _PostOption(label: 'House for Sale', icon: Icons.home_work_rounded),
    _PostOption(label: 'Apartment for Sale', icon: Icons.domain_rounded),
    _PostOption(label: 'Office Space', icon: Icons.business_center_rounded),
    _PostOption(label: 'Shop / Kiosk', icon: Icons.storefront_rounded),
    _PostOption(label: 'Warehouse', icon: Icons.warehouse_rounded),
    _PostOption(label: 'Land / Plot', icon: Icons.terrain_rounded),
  ];

  // Form state
  int? selectedIndex;
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final List<String> _photos = [];

  // Loading state
  bool _isPosting = false;

  @override
  void dispose() {
    _pageController.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  void _next(BuildContext context) {
    if (_isPosting) return;

    // Step validation
    if (!_validateCurrentStep()) return;

    if (_current < 4) {
      _navigateToNext();
    } else {
      _postToFirestore(context);
    }
  }

  bool _validateCurrentStep() {
    switch (_current) {
      case 0:
        if (selectedIndex == null) {
          _showToast('Please select a category');
          return false;
        }
        return true;
      case 1:
        if (titleCtrl.text.trim().isEmpty) {
          _showToast('Please enter a title');
          return false;
        }
        return true;
      case 2:
        if (locationCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
          _showToast('Please add location & price');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _navigateToNext() {
    setState(() => _current += 1);
    _pageController.animateToPage(
      _current,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_current == 0 || _isPosting) return;
    setState(() => _current -= 1);
    _pageController.animateToPage(
      _current,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _postToFirestore(BuildContext context) async {
    if (_isPosting) return;

    setState(() => _isPosting = true);

    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'category': _options[selectedIndex!].label,
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
        'photos': _photos,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'current_user_id', // Replace with actual user ID
      });

      _showToast('Property posted successfully!');

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showToast('Error posting: $e');
      setState(() => _isPosting = false);
    }
  }

  void _addPhoto() {
    setState(() => _photos.add('photo_${_photos.length + 1}.jpg'));
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: _PostFAB(
        currentStep: _current,
        isPosting: _isPosting,
        onPressed: () => _next(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _PostHeader(
              currentStep: _current,
              onBack: _back,
              primaryColor: primary,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  if (_current != index) {
                    setState(() => _current = index);
                  }
                },
                children: [
                  _CategoryStep(
                    options: _options,
                    selectedIndex: selectedIndex,
                    onSelect: (index) => setState(() => selectedIndex = index),
                  ),
                  _DetailsStep(
                    titleCtrl: titleCtrl,
                    descCtrl: descCtrl,
                  ),
                  _LocationPriceStep(
                    locationCtrl: locationCtrl,
                    priceCtrl: priceCtrl,
                  ),
                  _PhotosStep(
                    photos: _photos,
                    onAdd: _addPhoto,
                    onRemove: _removePhoto,
                  ),
                  _ReviewStep(
                    category: selectedIndex == null ? '' : _options[selectedIndex!].label,
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    location: locationCtrl.text,
                    price: priceCtrl.text,
                    photosCount: _photos.length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Extracted Floating Action Button
class _PostFAB extends StatelessWidget {
  final int currentStep;
  final bool isPosting;
  final VoidCallback onPressed;

  const _PostFAB({
    required this.currentStep,
    required this.isPosting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isPosting ? null : onPressed,
      shape: const CircleBorder(),
      child: isPosting
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
          : Icon(
        currentStep == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded,
        size: 24,
      ),
    );
  }
}

// Extracted Post Header
class _PostHeader extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final Color primaryColor;

  const _PostHeader({
    required this.currentStep,
    required this.onBack,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: currentStep == 0 ? null : onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _StepDots(
              current: currentStep,
              total: 5,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 48), // Balance FAB space
        ],
      ),
    );
  }
}

// Extracted Category Step
class _CategoryStep extends StatelessWidget {
  final List<_PostOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryStep({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _StepTitle(
            title: 'What are you posting?',
            theme: theme,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _CategoryOption(
                option: options[index],
                isSelected: selectedIndex == index,
                onTap: () => onSelect(index),
              ),
              childCount: options.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

// Extracted Category Option
class _CategoryOption extends StatelessWidget {
  final _PostOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.65) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.05),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withOpacity(0.10)
                      : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 36,
                  color: isSelected ? primary : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted Details Step
class _DetailsStep extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  const _DetailsStep({
    required this.titleCtrl,
    required this.descCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _FormStep(
      title: 'Basic details',
      children: [
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Listing title',
            hintText: 'e.g., 2-Bedroom Apartment in Salama Park',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descCtrl,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe the property, amenities, nearby places…',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// Extracted Location & Price Step
class _LocationPriceStep extends StatelessWidget {
  final TextEditingController locationCtrl;
  final TextEditingController priceCtrl;

  const _LocationPriceStep({
    required this.locationCtrl,
    required this.priceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _FormStep(
      title: 'Location & price',
      children: [
        TextField(
          controller: locationCtrl,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'e.g., Salama Park, Lusaka',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price',
            hintText: 'e.g., 9,500',
            border: OutlineInputBorder(),
            prefixText: 'ZMW ',
          ),
        ),
        const SizedBox(height: 12),
        const _Hint(text: 'Tip: Add a fair price to increase visibility.'),
      ],
    );
  }
}

// Reusable Form Step Layout
class _FormStep extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormStep({
    required this.title,
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
          _StepTitle(title: title, theme: theme),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// Extracted Photos Step
class _PhotosStep extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotosStep({
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
          _StepTitle(title: 'Add photos', theme: theme),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < photos.length; i++)
                _PhotoThumbnail(
                  photoPath: photos[i],
                  onRemove: () => onRemove(i),
                ),
              _AddPhotoButton(onTap: onAdd),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${photos.length} photo(s) selected',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const _Hint(text: 'Add at least 3 clear photos for best results.'),
        ],
      ),
    );
  }
}

// Extracted Photo Thumbnail
class _PhotoThumbnail extends StatelessWidget {
  final String photoPath;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
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

// Extracted Add Photo Button
class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

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

// Extracted Review Step
class _ReviewStep extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String location;
  final String price;
  final int photosCount;

  const _ReviewStep({
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.photosCount,
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
          _StepTitle(title: 'Review & post', theme: theme),
          const SizedBox(height: 16),
          _ReviewItem(label: 'Category', value: category),
          _ReviewItem(label: 'Title', value: title),
          _ReviewItem(label: 'Location', value: location),
          _ReviewItem(label: 'Price', value: 'ZMW $price'),
          const SizedBox(height: 8),
          _ReviewItem(
            label: 'Description',
            value: description,
            isMultiline: true,
          ),
          const SizedBox(height: 12),
          _ReviewItem(label: 'Photos', value: '$photosCount selected'),
          const SizedBox(height: 12),
          const _Hint(text: 'If everything looks good, tap the check button to post.'),
        ],
      ),
    );
  }
}

// Extracted Review Item
class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const _ReviewItem({
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isMultiline
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value, style: valueStyle),
        ],
      )
          : Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: valueStyle)),
        ],
      ),
    );
  }
}

// Common Components
class _StepTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _StepTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
      child: Center(
        child: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current, total;
  final Color color;

  const _StepDots({
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          height: 8,
          width: i == current ? 22 : 8,
          decoration: BoxDecoration(
            color: i == current ? color : Colors.black12,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _PostOption {
  final String label;
  final IconData icon;
  const _PostOption({required this.label, required this.icon});
}