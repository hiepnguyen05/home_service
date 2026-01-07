import 'package:flutter/material.dart';
import 'app.dart';
import 'providers/app_providers.dart';

void main() {
  runApp(
    const AppProviders(
      child: MyApp(),
    ),
  );
}