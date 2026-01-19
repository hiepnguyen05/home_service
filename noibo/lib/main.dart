import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'providers/app_providers.dart';
// import 'test_services_page.dart'; // Uncomment để test

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const AppProviders(
      child: MyApp(),
      // child: MaterialApp(home: TestServicesPage()), // Uncomment để test services
    ),
  );
}