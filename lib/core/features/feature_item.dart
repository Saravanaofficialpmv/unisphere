import 'package:flutter/material.dart';

class FeatureItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String category;
  final String? badge;
  final WidgetBuilder routeBuilder;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.category,
    this.badge,
    required this.routeBuilder,
  });
}
