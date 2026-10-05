import 'package:flutter/material.dart';
import 'features/navigation/presentation/main_nav_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EloFit',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        useMaterial3: true,
      ),
      home: const MainNavScreen(),
    );
  }
}

