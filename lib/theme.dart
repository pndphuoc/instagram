import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/ultis/colors.dart';

final theme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: mobileBackgroundColor,
  textTheme: GoogleFonts.readexProTextTheme().copyWith(
    bodyLarge: const TextStyle(
        color: onBackground,
        fontSize: 20,
        fontWeight: FontWeight.normal),
    bodyMedium: const TextStyle(
      color: onBackgroundSecondary,
    ),
    bodySmall: const TextStyle(color: onBackground),
    labelLarge: const TextStyle(
        color: onBackground, fontWeight: FontWeight.w300),
    displayLarge: const TextStyle(color: onBackground),
    displayMedium: const TextStyle(color: onBackground),
    displaySmall: const TextStyle(color: onBackground),
    headlineMedium: const TextStyle(color: onBackground),
    headlineSmall: const TextStyle(color: onBackground),
    titleLarge: const TextStyle(color: onBackground),
    labelSmall: const TextStyle(color: onBackground),
    labelMedium: const TextStyle(color: onBackground),
    titleMedium: const TextStyle(color: onBackground),
    titleSmall: const TextStyle(color: onBackground),
  ),
);