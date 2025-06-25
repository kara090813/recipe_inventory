import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData get defaultTheme{
    return ThemeData(
        fontFamily: 'Mapo',
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: 'Mapo'),
          displayMedium: TextStyle(fontFamily: 'Mapo'),
          displaySmall: TextStyle(fontFamily: 'Mapo'),
          headlineLarge: TextStyle(fontFamily: 'Mapo'),
          headlineMedium: TextStyle(fontFamily: 'Mapo'),
          headlineSmall: TextStyle(fontFamily: 'Mapo'),
          titleLarge: TextStyle(fontFamily: 'Mapo'),
          titleMedium: TextStyle(fontFamily: 'Mapo'),
          titleSmall: TextStyle(fontFamily: 'Mapo'),
          bodyLarge: TextStyle(fontFamily: 'Mapo'),
          bodyMedium: TextStyle(fontFamily: 'Mapo'),
          bodySmall: TextStyle(fontFamily: 'Mapo'),
          labelLarge: TextStyle(fontFamily: 'Mapo'),
          labelMedium: TextStyle(fontFamily: 'Mapo'),
          labelSmall: TextStyle(fontFamily: 'Mapo'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'Mapo'),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'Mapo'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'Mapo'),
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: 'Mapo'),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontFamily: 'Mapo'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Mapo'),
        ),
    );
  }
}