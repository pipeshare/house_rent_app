import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;

  NavigationItem(this.label, this.icon);
}

enum ProfessionalSpecialty {
  agent('Real Estate Agent'),
  broker('Mortgage Broker'),
  lawyer('Property Lawyer'),
  inspector('Home Inspector'),
  architect('Architect'),
  contractor('Contractor');

  final String displayName;
  const ProfessionalSpecialty(this.displayName);
}
