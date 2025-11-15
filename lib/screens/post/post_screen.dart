import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/steps/category_step.dart';
import 'package:house_rent_app/screens/post/steps/details_step.dart';
import 'package:house_rent_app/screens/post/steps/location_step.dart';
import 'package:house_rent_app/screens/post/steps/photos_step.dart';
import 'package:house_rent_app/screens/post/steps/review_step.dart';
import 'package:house_rent_app/services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'components/post_FAB.dart';
import 'components/post_header.dart';
import 'components/post_option.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _pageController = PageController();
  int _current = 0;
  final ImagePicker _picker = ImagePicker();

  // Cache for post options to prevent recreation
  static const List<PostOption> _options = [
    PostOption(label: 'House for Rent', icon: Icons.house_rounded),
    PostOption(label: 'Apartment for Rent', icon: Icons.apartment_rounded),
    PostOption(label: 'Short Let / BnB', icon: Icons.night_shelter_rounded),
    PostOption(label: 'House for Sale', icon: Icons.home_work_rounded),
    PostOption(label: 'Apartment for Sale', icon: Icons.domain_rounded),
    PostOption(label: 'Office Space', icon: Icons.business_center_rounded),
    PostOption(label: 'Shop / Kiosk', icon: Icons.storefront_rounded),
    PostOption(label: 'Warehouse', icon: Icons.warehouse_rounded),
    PostOption(label: 'Land / Plot', icon: Icons.terrain_rounded),
  ];

  // Form state
  int? selectedIndex;
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final List<String> _photos = [];
  final PostService _postService = PostService();

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

  Future<void> _next(BuildContext context) async {
    if (_isPosting) return;

    // Step validation
    if (!_validateCurrentStep()) return;

    if (_current < 4) {
      _navigateToNext();
    } else {
      await PostService().postProperty(
        context: context,
        category: _options[selectedIndex!].label,
        title: titleCtrl.text,
        description: descCtrl.text,
        location: locationCtrl.text,
        price: priceCtrl.text,
        photos: _photos,
        // List<String> of local file paths
        userId: FirebaseAuth.instance.currentUser!.uid,
      );
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

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _photos.add(image.path));
    }
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
      floatingActionButton: PostFAB(
        currentStep: _current,
        isPosting: _isPosting,
        onPressed: () => _next(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            PostHeader(
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
                  CategoryStep(
                    options: _options,
                    selectedIndex: selectedIndex,
                    onSelect: (index) => setState(() => selectedIndex = index),
                  ),
                  DetailsStep(
                    titleCtrl: titleCtrl,
                    descCtrl: descCtrl,
                  ),
                  LocationPriceStep(
                    locationCtrl: locationCtrl,
                    priceCtrl: priceCtrl,
                  ),
                  PhotosStep(
                    photos: _photos,
                    onAdd: _addPhoto,
                    onRemove: _removePhoto,
                  ),
                  ReviewStep(
                    category: selectedIndex == null
                        ? ''
                        : _options[selectedIndex!].label,
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
