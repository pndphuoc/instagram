import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/ultis/colors.dart';

final theme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: mobileBackgroundColor,
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.beVietnamPro(
        color: onBackground,
        fontSize: 20,
        fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.beVietnamPro(
      color: onBackgroundSecondary,
    ),
    bodySmall: GoogleFonts.beVietnamPro(color: onBackground),
    labelLarge: GoogleFonts.beVietnamPro(
        color: onBackground, fontWeight: FontWeight.w300),
    displayLarge: GoogleFonts.beVietnamPro(color: onBackground),
    displayMedium: GoogleFonts.beVietnamPro(color: onBackground),
    displaySmall: GoogleFonts.beVietnamPro(color: onBackground),
    headlineMedium: GoogleFonts.beVietnamPro(color: onBackground),
    headlineSmall: GoogleFonts.beVietnamPro(color: onBackground),
    titleLarge: GoogleFonts.beVietnamPro(color: onBackground),
    labelSmall: GoogleFonts.beVietnamPro(color: onBackground),
    labelMedium: GoogleFonts.beVietnamPro(color: onBackground),
    titleMedium: GoogleFonts.beVietnamPro(color: onBackground),
    titleSmall: GoogleFonts.beVietnamPro(color: onBackground),
  ),
);