import 'package:flutter/material.dart';
import '/pages/login.dart';

void main() {
  runApp(const SafeClaimApp());
}

class SafeClaimApp extends StatelessWidget {
  const SafeClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
