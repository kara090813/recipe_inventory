import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData get defaultTheme{
    return ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme:TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Mapo'),

        )
    );
  }
}