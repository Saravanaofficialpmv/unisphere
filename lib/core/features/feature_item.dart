import 'package:flutter/material.dart';

class FeatureItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageAsset;
  final Color color;
  final Color pastelBg;
  final String category;
  final String? badge;
  final WidgetBuilder routeBuilder;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageAsset,
    required this.color,
    required this.pastelBg,
    required this.category,
    this.badge,
    required this.routeBuilder,
  });
}
