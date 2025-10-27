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

  // STEP 1 (category)
  int? selectedIndex;
  final List<_PostOption> options = const [
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

  // STEP 2 (basic details)
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // STEP 3 (location & price)
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // STEP 4 (photos) – demo state only
  final List<String> mockPhotos = [];

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
    // Minimal per-step validation
    if (_current == 0 && selectedIndex == null) {
      _toast(context, 'Please select a category');
      return;
    }
    if (_current == 1 && titleCtrl.text.trim().isEmpty) {
      _toast(context, 'Please enter a title');
      return;
    }
    if (_current == 2 &&
        (locationCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty)) {
      _toast(context, 'Please add location & price');
      return;
    }

    if (_current < 4) {
      setState(() => _current += 1);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      // POST action
      _postToFirestore(context);
      Navigator.of(context).maybePop();
    }
  }

  void _postToFirestore(BuildContext context) async {
    final completer = Completer<void>();

    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'category': options[selectedIndex!].label,
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
        'photos': mockPhotos,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'current_user_id',
      });

      // Show success and wait a bit before navigating
      _toast(context, 'Property posted successfully!');
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _toast(context, 'Error posting: $e');
      }
    }
  }

  void _back() {
    if (_current == 0) return;
    setState(() => _current -= 1);
    _pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _next(context),
        shape: const CircleBorder(),
        child: Icon(
            _current == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _current == 0 ? null : _back,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _StepDots(
                          current: _current, total: 5, color: primary)),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // use buttons to advance
                children: [
                  _CategoryStep(
                    titleSize: 37,
                    options: options,
                    selectedIndex: selectedIndex,
                    onSelect: (i) => setState(() => selectedIndex = i),
                  ),
                  _DetailsStep(
                    titleSize: 37,
                    titleCtrl: titleCtrl,
                    descCtrl: descCtrl,
                  ),
                  _LocationPriceStep(
                    titleSize: 37,
                    locationCtrl: locationCtrl,
                    priceCtrl: priceCtrl,
                  ),
                  _PhotosStep(
                    titleSize: 37,
                    photos: mockPhotos,
                    onAdd: _addMockPhoto,
                    onRemove: _removeMockPhoto,
                    imagePaths: const [],
                  ),
                  _ReviewStep(
                    titleSize: 37,
                    chosen: selectedIndex == null
                        ? ''
                        : options[selectedIndex!].label,
                    title: titleCtrl.text,
                    desc: descCtrl.text,
                    location: locationCtrl.text,
                    price: priceCtrl.text,
                    photosCount: mockPhotos.length,
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

  void _addMockPhoto() {
    setState(() => mockPhotos.add('photo_${mockPhotos.length + 1}.jpg'));
  }

  void _removeMockPhoto(int index) {
    setState(() => mockPhotos.removeAt(index));
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.titleSize,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  final double titleSize;
  final List<_PostOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final cardColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface.withOpacity(0.9);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'What are you posting?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
                fontSize: titleSize,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final opt = options[index];
              final selected = selectedIndex == index;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          selected ? primary.withOpacity(0.65) : Colors.black12,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: selected ? 10 : 6,
                        offset: const Offset(0, 3),
                        color: Colors.black.withOpacity(selected ? 0.08 : 0.05),
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
                            color: selected
                                ? primary.withOpacity(0.10)
                                : Colors.black.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(opt.icon,
                              size: 36,
                              color: selected ? primary : Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          opt.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.titleSize,
    required this.titleCtrl,
    required this.descCtrl,
  });

  final double titleSize;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontSize: titleSize,
            ),
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }
}

class _LocationPriceStep extends StatelessWidget {
  const _LocationPriceStep({
    required this.titleSize,
    required this.locationCtrl,
    required this.priceCtrl,
  });

  final double titleSize;
  final TextEditingController locationCtrl;
  final TextEditingController priceCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location & price',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontSize: titleSize,
            ),
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }
}

class _PhotosStep extends StatelessWidget {
  const _PhotosStep({
    required this.titleSize,
    required this.imagePaths,
    required this.onAdd,
    required this.onRemove,
    required List<String> photos,
  });

  final double titleSize;
  final List<String> imagePaths;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add photos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontSize: titleSize,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < imagePaths.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(imagePaths[i])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () => onRemove(i),
                        icon: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 16),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              InkWell(
                onTap: onAdd,
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${imagePaths.length} photo(s) selected',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const _Hint(text: 'Add at least 3 clear photos for best results.'),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.titleSize,
    required this.chosen,
    required this.title,
    required this.desc,
    required this.location,
    required this.price,
    required this.photosCount,
  });

  final double titleSize;
  final String chosen, title, desc, location, price;
  final int photosCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]);
    final valueStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & post',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontSize: titleSize,
            ),
          ),
          const SizedBox(height: 16),
          _ReviewRow(
              label: 'Category',
              value: chosen,
              labelStyle: labelStyle,
              valueStyle: valueStyle),
          _ReviewRow(
              label: 'Title',
              value: title,
              labelStyle: labelStyle,
              valueStyle: valueStyle),
          _ReviewRow(
              label: 'Location',
              value: location,
              labelStyle: labelStyle,
              valueStyle: valueStyle),
          _ReviewRow(
              label: 'Price',
              value: 'ZMW $price',
              labelStyle: labelStyle,
              valueStyle: valueStyle),
          const SizedBox(height: 8),
          Text('Description', style: labelStyle),
          const SizedBox(height: 4),
          Text(desc.isEmpty ? '—' : desc, style: valueStyle),
          const SizedBox(height: 12),
          _ReviewRow(
            label: 'Photos',
            value: '$photosCount selected',
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          const SizedBox(height: 12),
          const _Hint(
              text: 'If everything looks good, tap the check button to post.'),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label, value;
  final TextStyle? labelStyle, valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: valueStyle)),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

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
  const _StepDots(
      {required this.current, required this.total, required this.color});
  final int current, total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
