import 'package:flutter/cupertino.dart';


class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFFFFAB40); // Amber/beer color
  static const Color secondaryColor = Color(0xFF8D6E63); // Brown/wood color
  static const Color accentColor = Color(0xFFFF5722); // Deep orange for accents

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFC107);

  // Glassmorphism properties
  static const double glassmorphismOpacity = 0.2;
  static const double glassmorphismBlur = 10.0;
  static const BorderRadius glassmorphismBorderRadius = BorderRadius.all(Radius.circular(16.0));

  // Text styles
  static const TextStyle headlineStyle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: primaryTextColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor,
  );

  // CupertinoThemeData for the app
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryColor,
      barBackgroundColor: backgroundColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryTextColor,
        textStyle: bodyStyle,
        navTitleTextStyle: titleStyle,
        navLargeTitleTextStyle: headlineStyle,
        navActionTextStyle: subtitleStyle,
        tabLabelTextStyle: captionStyle,
      ),
    );
  }
}
