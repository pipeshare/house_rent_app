import 'package:flutter/material.dart';

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
