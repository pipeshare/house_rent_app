import 'dart:async';
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
  bool _isUploading = false;

  // Cache for user data to prevent unnecessary rebuilds
  static const _defaultAvatar = 'https://i.pravatar.cc/150?img=12';

  // Firestore document cache
  DocumentSnapshot? _cachedUserDoc;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    debugPrint('_initializeUser started');
    // Use a timer to handle timeout instead of .timeout() on Future
    Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        debugPrint('User loading timed out - forcing stop');
        setState(() => _isLoading = false);
      }
    });

    _loadCurrentUser();
    _setupUserListener();
  }

  void _setupUserListener() {
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && mounted) {
          debugPrint('User data updated from stream');
          _cachedUserDoc = doc;
          _updateUserFromDoc(doc);
        }
      }, onError: (error) {
        debugPrint('User stream error: $error');
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  void _updateUserFromDoc(DocumentSnapshot doc) {
    try {
      final userData = doc.data() as Map<String, dynamic>;
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null && mounted) {
        setState(() {
          _currentUser = kUser.User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? 'No email',
            fullName: userData['fullName'] ?? firebaseUser.displayName ?? 'User',
            profileImageUrl: userData['photoURL'] ??
                firebaseUser.photoURL ??
                _defaultAvatar,
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _isLoading = false;
        });
        debugPrint('User updated from document successfully');
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error updating user from doc: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    debugPrint('_loadCurrentUser started');
    try {
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      debugPrint('Firebase user: ${firebaseUser?.uid}');

      if (firebaseUser == null) {
        debugPrint('No Firebase user found - stopping loading');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Verify the user is still valid
      await firebaseUser.reload();
      final updatedUser = fb_auth.FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        debugPrint('User reload failed - stopping loading');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Use cache if available
      if (_cachedUserDoc != null && _cachedUserDoc!.exists) {
        debugPrint('Using cached user document');
        _updateUserFromDoc(_cachedUserDoc!);
        return;
      }

      // Fetch from Firestore
      debugPrint('Fetching user from Firestore...');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      _cachedUserDoc = userDoc;

      if (userDoc.exists) {
        debugPrint('User document found in Firestore');
        _updateUserFromDoc(userDoc);
      } else {
        debugPrint('User document not found - creating default user');
        // Create default user if document doesn't exist
        _setDefaultUser(firebaseUser);
        // Optionally create user document in background
        _createUserInFirestoreIfNeeded(firebaseUser);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _setDefaultUser(firebaseUser);
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setDefaultUser(fb_auth.User firebaseUser) {
    if (mounted) {
      setState(() {
        _currentUser = kUser.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? 'No email',
          fullName: firebaseUser.displayName ?? 'User',
          profileImageUrl: firebaseUser.photoURL ?? _defaultAvatar,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isLoading = false;
      });
      debugPrint('Default user set successfully');
    }
  }

  Future<void> _createUserInFirestoreIfNeeded(fb_auth.User firebaseUser) async {
    try {
      debugPrint('Creating user document in Firestore...');
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
        'fullName': firebaseUser.displayName,
        'email': firebaseUser.email,
        'photoURL': firebaseUser.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('User document created successfully');
    } catch (e) {
      debugPrint('Error creating user doc: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const _ProfileLoadingScreen();
    }

    return _ProfileContent(
      user: _currentUser,
      isUploading: _isUploading,
      onLogout: _logout,
      onChangeProfileImage: _changeProfileImage,
      onCreatePost: _navigateToCreatePost,
    );
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
              Navigator.pop(context);
              try {
                await fb_auth.FirebaseAuth.instance.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
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
    if (_isUploading) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        await _uploadProfileImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    if (!mounted || _isUploading) return;

    setState(() => _isUploading = true);

    final supabase = SupabaseClient(kSupabaseUrl, kSupabaseAnonKey);
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null || !await imageFile.exists()) {
      setState(() => _isUploading = false);
      return;
    }

    try {
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase
      await supabase.storage.from('users').upload(fileName, imageFile);
      final String publicUrl = supabase.storage.from('users').getPublicUrl(fileName);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'photoURL': publicUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      debugPrint('Upload error details: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

// Updated Loading Screen with timeout
class _ProfileLoadingScreen extends StatefulWidget {
  const _ProfileLoadingScreen();

  @override
  State<_ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<_ProfileLoadingScreen> {
  bool _showError = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Show error message after 15 seconds
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _showError = true);
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: _showError
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: kErrorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading timeout',
              style: TextStyle(
                color: kTitleColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection',
              style: TextStyle(
                color: kBodyTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry loading
                final state = context.findAncestorStateOfType<_ProfileScreenState>();
                state?._loadCurrentUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
              ),
              child: const Text('Retry'),
            ),
          ],
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: kBodyTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Extracted Profile Content
class _ProfileContent extends StatelessWidget {
  final kUser.User user;
  final bool isUploading;
  final VoidCallback onLogout;
  final VoidCallback onChangeProfileImage;
  final VoidCallback onCreatePost;

  const _ProfileContent({
    required this.user,
    required this.isUploading,
    required this.onLogout,
    required this.onChangeProfileImage,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      floatingActionButton: isSmallScreen
          ? FloatingActionButton(
        onPressed: onCreatePost,
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
            _ProfileHeader(
              user: user,
              isSmallScreen: isSmallScreen,
              isUploading: isUploading,
              onChangeProfileImage: onChangeProfileImage,
            ),
            const SizedBox(height: 18),
            _QuickActionsSection(
              isSmallScreen: isSmallScreen,
              onCreatePost: onCreatePost,
            ),
            _MenuSection(user: user),
          ],
        ),
      ),
    );
  }
}

// Extracted Profile Header
class _ProfileHeader extends StatelessWidget {
  final kUser.User user;
  final bool isSmallScreen;
  final bool isUploading;
  final VoidCallback onChangeProfileImage;

  const _ProfileHeader({
    required this.user,
    required this.isSmallScreen,
    required this.isUploading,
    required this.onChangeProfileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              GestureDetector(
                onTap: isUploading ? null : onChangeProfileImage,
                child: CircleAvatar(
                  radius: isSmallScreen ? 60 : 70,
                  backgroundImage: NetworkImage(user.profileImageUrl.toString()),
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
              if (!isUploading)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onChangeProfileImage,
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
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 60 : 70),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: kWhite),
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
    );
  }
}

// Extracted Quick Actions Section
class _QuickActionsSection extends StatelessWidget {
  final bool isSmallScreen;
  final VoidCallback onCreatePost;

  const _QuickActionsSection({
    required this.isSmallScreen,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        if (!isSmallScreen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: ElevatedButton.icon(
              onPressed: onCreatePost,
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
      ],
    );
  }
}

// Extracted Menu Section
class _MenuSection extends StatelessWidget {
  final kUser.User user;

  const _MenuSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Your listings
        GestureDetector(
          onTap: () {
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
        // Other menu items...
        const SettingTile(
          icon: Icons.assignment_rounded,
          title: 'Applications',
          subtitle: 'View rental applications',
        ),
        const SettingTile(
          icon: Icons.payment_rounded,
          title: 'Payments',
          subtitle: 'Rent payments & history',
          trailing: StatusDot(color: kSuccessColor),
        ),
        const SizedBox(height: 8),
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
        _SignOutButton(onLogout: () {
          // Get the context from the widget tree
          final state = context.findAncestorStateOfType<_ProfileScreenState>();
          state?._logout();
        }),
        const _AppVersionText(),
      ],
    );
  }
}

// Extracted Sign Out Button
class _SignOutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _SignOutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: onLogout,
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
    );
  }
}

// Extracted App Version Text
class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'House Rent App v1.0.0',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kBodyTextColor,
          fontSize: 12,
        ),
      ),
    );
  }
}