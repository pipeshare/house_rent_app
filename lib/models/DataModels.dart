import 'package:flutter/material.dart';

class Professional {
  final String name;
  final String specialty;
  final String imageUrl;

  Professional(this.name, this.specialty, this.imageUrl);
}

// Data Models
class NavigationItem {
  final String label;
  final IconData icon;

  NavigationItem(this.label, this.icon);
}

class Category {
  final String name;
  final IconData icon;

  Category(this.name, this.icon);
}
