import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const LinklessBrowserApp());
}

class LinklessBrowserApp extends StatelessWidget {
  const LinklessBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linkless Browser',
      debugShowCheckedModeBanner: false,

      // Apply custom liquid glass themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme by default
      // Home screen with Browser and History tabs
      home: const HomeScreen(),
    );
  }
}
