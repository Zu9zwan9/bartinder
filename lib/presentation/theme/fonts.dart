import 'package:flutter/material.dart';

/// Typography constants for the app following Apple Human Interface Guidelines
class AppFonts {
  // Font families
  static const String sfProDisplay = 'SF Pro Display';
  static const String sfProText = 'SF Pro Text';

  // Font weights
  static const FontWeight ultraLight = FontWeight.w100;
  static const FontWeight thin = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Letter spacing following iOS conventions
  static const double tightLetterSpacing = -0.5;
  static const double normalLetterSpacing = 0.0;
  static const double looseLetterSpacing = 0.5;

  // Line height multipliers
  static const double standardLineHeight = 1.3;
  static const double tightLineHeight = 1.1;
  static const double looseLineHeight = 1.5;

  // Text styles for dynamic type
  static TextStyle largeTitle({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProDisplay,
      fontSize: 34,
      fontWeight: weight ?? bold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle title1({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProDisplay,
      fontSize: 28,
      fontWeight: weight ?? bold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle title2({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProDisplay,
      fontSize: 22,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle title3({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProDisplay,
      fontSize: 20,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle headline({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 17,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle body({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 17,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle callout({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 16,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle subhead({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 15,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle footnote({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 13,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? normalLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle caption1({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 12,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? normalLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle caption2({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 11,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacing ?? normalLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  // Special text styles
  static TextStyle button({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 17,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle navTitle({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProDisplay,
      fontSize: 17,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacing ?? tightLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  static TextStyle tabBar({Color? color, FontWeight? weight, double? letterSpacing}) {
    return TextStyle(
      fontFamily: sfProText,
      fontSize: 10,
      fontWeight: weight ?? medium,
      letterSpacing: letterSpacing ?? normalLetterSpacing,
      height: standardLineHeight,
      decoration: TextDecoration.none,
      color: color,
    );
  }
}
