import 'package:flutter/material.dart';

/// Maps icon names (string) from Firestore/Admin Web to Flutter IconData.
/// Matches the list in `admin_web\src\constants\icons.js`.
class IconHelper {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'water_drop':
        return Icons.water_drop;
      case 'bolt':
        return Icons.bolt;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'format_paint':
        return Icons.format_paint;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'construction':
        return Icons.construction;
      case 'pest_control':
        return Icons.pest_control;
      case 'yard':
        return Icons.yard;
      case 'plumbing':
        return Icons.plumbing;
      case 'build':
        return Icons.build;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'settings':
        return Icons.settings;
      default:
        // Return a default icon or a specific one for "unknown"
        return Icons.help_outline;
    }
  }
}
