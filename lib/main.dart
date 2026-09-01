import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_screen.dart';

void main() {
  runApp(const HemantGymApp());
}

class HemantGymApp extends StatelessWidget {
  const HemantGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hemant Gym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6236FF),
          primary: const Color(0xFF6236FF),
          background: const Color(0xFFF8F9FE),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1E1E1E),
          displayColor: const Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF1E1E1E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      ),
      home: const MainScreen(),
    );
  }
}
