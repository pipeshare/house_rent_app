// lib/routes/route_arguments.dart
import 'package:house_rent_app/models/user.dart';

class ProfileArguments {
  final String userId;
  final bool isEditable;

  ProfileArguments({required this.userId, this.isEditable = false});
}

class EditProfileArguments {
  final User user;

  EditProfileArguments({required this.user});
}

// Add more argument classes as needed