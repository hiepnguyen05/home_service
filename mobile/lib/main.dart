import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Center(
        child: Text(
          "Home Page HomeService",
          style: TextStyle(color: Color(0xFF4CAE4F), fontSize: 30),
        ),
      ),
    );
  }
}
