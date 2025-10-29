import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:house_rent_app/models/user.dart' as kUser;
import 'package:house_rent_app/core/constants.dart';
import 'package:house_rent_app/screens/listing/listing_screen.dart';
import 'package:house_rent_app/screens/post/post_screen.dart';
import 'package:house_rent_app/screens/profile/setting_tile.dart';
import 'package:house_rent_app/screens/profile/stat_chip.dart';
import 'package:house_rent_app/screens/profile/status_dot.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase/supabase.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  late kUser.User _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _buildProfileScreen(_currentUser);
  }

  Future<void> _loadCurrentUser() async {
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      try {
        // Fetch additional user details from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _currentUser = kUser.User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? 'No email',
              fullName:
                  userData['fullName'] ?? firebaseUser.displayName ?? 'User',
              profileImageUrl: userData['photoURL'] ??
                  userData['photoURL'] ??
                  firebaseUser.photoURL ??
                  'https://i.pravatar.cc/150?img=12',
              isEmailVerified: firebaseUser.emailVerified,
              createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              updatedAt: DateTime.now(),
              // Add any other fields from Firestore
            );
          });
        } else {
          // User document doesn't exist in Firestore, create with basic info
          setState(() {
            _currentUser = kUser.User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? 'No email',
              fullName: firebaseUser.displayName ?? 'User',
              profileImageUrl:
                  firebaseUser.photoURL ?? 'https://i.pravatar.cc/150?img=12',
              isEmailVerified: firebaseUser.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          });

          // Optionally create the user document in Firestore
          // await _createUserInFirestore(_currentUser!);
        }

        log(_currentUser.toString());
        _isLoading = false;
      } catch (e) {
        print('Error loading user data: $e');
        // Fallback to basic auth data if Firestore fails
        setState(() {
          _currentUser = kUser.User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? 'No email',
            fullName: firebaseUser.displayName ?? 'User',
            profileImageUrl:
                firebaseUser.photoURL ?? 'https://i.pravatar.cc/150?img=12',
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await fb_auth.FirebaseAuth.instance.signOut();
                // AuthWrapper will automatically detect the sign-out and show login screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );

                // Optional: Force navigation if needed
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   '/',
                //   (route) => false
                // );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: kErrorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostScreen()),
    );
  }

  Future<void> _changeProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // For Android, use image_picker's built-in crop option
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (image != null) {
        // For simple square cropping, you can use this approach
        await _uploadProfileImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    final supabase = SupabaseClient(kSupabaseUrl, kSupabaseAnonKey);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Get current user ID from Firebase Auth
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }
      final String userId = firebaseUser.uid;

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Upload image to Supabase Storage
      final uploadResponse =
          await supabase.storage.from('users').upload(fileName, imageFile);

      // throw Exception('Upload failed: ${uploadResponse.!.message}');

      // 2. Get public URL from Supabase
      final String publicUrl =
          supabase.storage.from('users').getPublicUrl(fileName);

      log('Image uploaded. URL: $publicUrl');

      // 3. Update user record in Firebase Database (not Supabase)
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'photoURL': publicUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );

      // Refresh UI
      setState(() {});
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      print('Upload error details: $e');
    }
  }

  Widget _buildProfileScreen(kUser.User user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      floatingActionButton: isSmallScreen
          ? FloatingActionButton(
              onPressed: _navigateToCreatePost,
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              tooltip: 'Create Listing',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            isSmallScreen ? 80 : 24,
          ),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _changeProfileImage,
                        child: CircleAvatar(
                          radius: isSmallScreen ? 60 : 70,
                          backgroundImage: NetworkImage(
                            user.profileImageUrl.toString(),
                          ),
                        ),
                      ),
                      if (user.isEmailVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: kPrimaryColor,
                              size: 14,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changeProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kWhite, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: kWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 30,
                                fontWeight: FontWeight.w800,
                                color: kTitleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: kBodyTextColor,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                StatChip(
                                  icon: Icons.home_work_rounded,
                                  label: 'Listings',
                                  value: '3',
                                  isSmall: isSmallScreen,
                                ),
                                StatChip(
                                  icon: Icons.bookmark_border_rounded,
                                  label: 'Saved',
                                  value: '12',
                                  isSmall: isSmallScreen,
                                ),
                                StatChip(
                                  icon: Icons.star_border_rounded,
                                  label: 'Reviews',
                                  value: '4.8',
                                  isSmall: isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: kTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Create Listing Button
            if (!isSmallScreen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: ElevatedButton.icon(
                  onPressed: _navigateToCreatePost,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Create New Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    foregroundColor: kPrimaryColor,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (!isSmallScreen) const SizedBox(height: 16),

            // Menu Items
            _buildMenuSection(user, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(kUser.User user, bool isSmallScreen) {
    return Column(
      children: [
        // Your listings
        GestureDetector(
          // behavior: HitTestBehavior.opaque,
          onTap: () {
            print(user);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ListingsScreen()),
            );
          },
          child: const SettingTile(
            icon: Icons.apartment_rounded,
            title: 'My Listings',
            subtitle: 'Manage your rental properties',
          ),
        ),
        const SizedBox(height: 8),

        // Rental Applications
        const SettingTile(
          icon: Icons.assignment_rounded,
          title: 'Applications',
          subtitle: 'View rental applications',
        ),

        // Payments
        const SettingTile(
          icon: Icons.payment_rounded,
          title: 'Payments',
          subtitle: 'Rent payments & history',
          trailing: StatusDot(color: kSuccessColor),
        ),

        const SizedBox(height: 8),

        // Account Settings
        const SettingTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
        ),
        SettingTile(
          icon: Icons.verified_user_outlined,
          title: 'Verification',
          subtitle: 'Complete KYC verification',
          trailing: StatusDot(
              color: user.isEmailVerified ? kSuccessColor : kWarningColor),
        ),
        const SettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Manage alerts and preferences',
        ),
        const SettingTile(
          icon: Icons.security_rounded,
          title: 'Privacy & Security',
          subtitle: 'Data and account security',
        ),
        const SettingTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQ and customer support',
        ),

        const SizedBox(height: 24),

        // Sign out button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: kWhite),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kErrorColor,
              foregroundColor: kWhite,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // App version and info
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'House Rent App v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBodyTextColor.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
