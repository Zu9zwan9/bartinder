import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fonts.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  // Theme mode
  static late ThemeMode _themeMode;
  static ThemeMode get themeMode => _themeMode;

  // Initialize theme
  static void initialize() {
    _themeMode = ThemeMode.system;
  }

  // Theme mode toggle
  static void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }

  // Check if dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Dynamic colors
  static Color dynamicColor(
    BuildContext context,
    Color lightColor,
    Color darkColor,
  ) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  // Font constants - delegated to AppFonts class
  static const String sfProDisplay = AppFonts.sfProDisplay;
  static const String sfProText = AppFonts.sfProText;

  // Brand palette (Apple HIG)
  static const Color mineShaft = Color(0xFF302E2F);
  static const Color rajah = Color(0xFFF5BF75);
  static const Color paleOyster = Color(0xFF948C74);
  static const Color schooner = Color(0xFF8C847C);

  // Brand Colors
  static const Color primaryColor = rajah;
  static const Color primaryDarkColor = rajah;
  static const Color accentColor = paleOyster;
  static const Color accentDarkColor = schooner;

  // iOS System Colors - Light
  static const Color systemRedLight = Color(0xFFFF3B30);
  static const Color systemOrangeLight = Color(0xFFFF9500);
  static const Color systemYellowLight = Color(0xFFFFCC00);
  static const Color systemGreenLight = Color(0xFF34C759);
  static const Color systemMintLight = Color(0xFF00C7BE);
  static const Color systemTealLight = Color(0xFF30B0C7);
  static const Color systemCyanLight = Color(0xFF32ADE6);
  static const Color systemBlueLight = Color(0xFF007AFF);
  static const Color systemIndigoLight = Color(0xFF5856D6);
  static const Color systemPurpleLight = Color(0xFFAF52DE);
  static const Color systemPinkLight = Color(0xFFFF2D55);
  static const Color systemBrownLight = Color(0xFFA2845E);
  static const Color systemGrayLight = Color(0xFF8E8E93);
  static const Color systemGray2Light = Color(0xFFAEAEB2);
  static const Color systemGray3Light = Color(0xFFC7C7CC);
  static const Color systemGray4Light = Color(0xFFD1D1D6);
  static const Color systemGray5Light = Color(0xFFE5E5EA);
  static const Color systemGray6Light = Color(0xFFF2F2F7);

  // iOS System Colors - Dark
  static const Color systemRedDark = Color(0xFFFF453A);
  static const Color systemOrangeDark = Color(0xFFFF9F0A);
  static const Color systemYellowDark = Color(0xFFFFD60A);
  static const Color systemGreenDark = Color(0xFF30D158);
  static const Color systemMintDark = Color(0xFF66D4CF);
  static const Color systemTealDark = Color(0xFF40C8E0);
  static const Color systemCyanDark = Color(0xFF64D2FF);
  static const Color systemBlueDark = Color(0xFF0A84FF);
  static const Color systemIndigoDark = Color(0xFF5E5CE6);
  static const Color systemPurpleDark = Color(0xFFBF5AF2);
  static const Color systemPinkDark = Color(0xFFFF375F);
  static const Color systemBrownDark = Color(0xFFB59469);
  static const Color systemGrayDark = Color(0xFF8E8E93);
  static const Color systemGray2Dark = Color(0xFF636366);
  static const Color systemGray3Dark = Color(0xFF48484A);
  static const Color systemGray4Dark = Color(0xFF3A3A3C);
  static const Color systemGray5Dark = Color(0xFF2C2C2E);
  static const Color systemGray6Dark = Color(0xFF1C1C1E);

  // Light theme colors (following iOS conventions)
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Color(0xFF000000);
  static const Color lightSecondaryTextColor = systemGrayLight;
  static const Color lightDividerColor = systemGray4Light;
  static const Color lightIconColor = systemGrayLight;
  static const Color lightErrorColor = systemRedLight;
  static const Color lightSuccessColor = systemGreenLight;

  // Dark theme colors (following iOS conventions)
  static const Color darkBackgroundColor = mineShaft;
  static const Color darkCardColor = systemGray5Dark;
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSecondaryTextColor = systemGrayDark;
  static const Color darkDividerColor = systemGray3Dark;
  static const Color darkIconColor = systemGrayDark;
  static const Color darkErrorColor = systemRedDark;
  static const Color darkSuccessColor = systemGreenDark;

  // Additional dark mode colors
  static const Color darkPrimaryColorVariant = Color(0xFFB35900);
  static const Color darkSurfaceColor = systemGray4Dark;
  static const Color darkBottomNavColor = systemGray5Dark;
  static const Color darkCardShadowColor = Color(0xFF000000);
  static const Color darkSeparatorColor = Color(0x1FFFFFFF); // 12% white

  // Dynamic color accessors
  static Color backgroundColor(BuildContext context) =>
      dynamicColor(context, lightBackgroundColor, darkBackgroundColor);
  static Color cardColor(BuildContext context) =>
      dynamicColor(context, lightCardColor, darkCardColor);
  static Color textColor(BuildContext context) =>
      dynamicColor(context, lightTextColor, darkTextColor);
  static Color secondaryTextColor(BuildContext context) =>
      dynamicColor(context, lightSecondaryTextColor, darkSecondaryTextColor);
  static Color dividerColor(BuildContext context) =>
      dynamicColor(context, lightDividerColor, darkDividerColor);
  static Color iconColor(BuildContext context) =>
      dynamicColor(context, lightIconColor, darkIconColor);
  static Color errorColor(BuildContext context) =>
      dynamicColor(context, lightErrorColor, darkErrorColor);
  static Color successColor(BuildContext context) =>
      dynamicColor(context, lightSuccessColor, darkSuccessColor);
  static Color secondaryColor(BuildContext context) =>
      dynamicColor(context, accentColor, accentDarkColor);
  static Color systemBlue(BuildContext context) =>
      dynamicColor(context, systemBlueLight, systemBlueDark);
  static Color systemGreen(BuildContext context) =>
      dynamicColor(context, systemGreenLight, systemGreenDark);
  static Color systemRed(BuildContext context) =>
      dynamicColor(context, systemRedLight, systemRedDark);
  static Color systemPink(BuildContext context) =>
      dynamicColor(context, systemPinkLight, systemPinkDark);
  static Color systemOrange(BuildContext context) =>
      dynamicColor(context, systemOrangeLight, systemOrangeDark);
  static Color systemGray(BuildContext context) =>
      dynamicColor(context, systemGrayLight, systemGrayDark);
  static Color systemGray2(BuildContext context) =>
      dynamicColor(context, systemGray2Light, systemGray2Dark);
  static Color systemGray3(BuildContext context) =>
      dynamicColor(context, systemGray3Light, systemGray3Dark);
  static Color systemGray4(BuildContext context) =>
      dynamicColor(context, systemGray4Light, systemGray4Dark);
  static Color systemGray5(BuildContext context) =>
      dynamicColor(context, systemGray5Light, systemGray5Dark);
  static Color systemGray6(BuildContext context) =>
      dynamicColor(context, systemGray6Light, systemGray6Dark);

  // Typography - using the AppFonts class for iOS standard text styles
  static final TextStyle largeTitle = AppFonts.largeTitle();
  static final TextStyle title1 = AppFonts.title1();
  static final TextStyle title2 = AppFonts.title2();
  static final TextStyle title3 = AppFonts.title3();
  static final TextStyle headline = AppFonts.headline();
  static final TextStyle body = AppFonts.body();
  static final TextStyle callout = AppFonts.callout();
  static final TextStyle subhead = AppFonts.subhead();
  static final TextStyle footnote = AppFonts.footnote();
  static final TextStyle caption1 = AppFonts.caption1();
  static final TextStyle caption2 = AppFonts.caption2();
  static final TextStyle button = AppFonts.button();
  static final TextStyle navTitle = AppFonts.navTitle();
  static final TextStyle tabBar = AppFonts.tabBar();

  // Backwards compatibility with existing codebase
  static final TextStyle titleStyle = title3;
  static final TextStyle subtitleStyle = headline;
  static final TextStyle bodyStyle = body;
  static final TextStyle captionStyle = footnote;
  static final TextStyle headlineStyle = title1;
  static final TextStyle buttonStyle = button;
  static final TextStyle smallStyle = subhead;
  static final TextStyle smallText = caption1; // Добавлено для работы с маркерами карты

  static const double glassmorphismBlur = 10.0;

  // iOS UI Constants
  static const double cornerRadius = 10.0;
  static const double smallCornerRadius = 6.0;
  static const double largeCornerRadius = 16.0;
  static const double standardElevation = 1.0;
  static const double modalElevation = 4.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Light Theme (following iOS standards)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: lightCardColor,
    canvasColor: lightBackgroundColor,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      error: lightErrorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: lightTextColor,
      primaryContainer: Color(0xFFF9E0CE), // Light amber for containers
      onPrimaryContainer: primaryDarkColor,
      secondaryContainer: Color(0xFFD1E9F7), // Light blue for containers
      onSecondaryContainer: accentDarkColor,
      surfaceContainerHighest: systemGray5Light,
      onSurfaceVariant: lightSecondaryTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: navTitle.copyWith(color: lightTextColor),
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightIconColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: tabBar.copyWith(color: primaryColor),
      unselectedLabelStyle: tabBar.copyWith(color: lightIconColor),
    ),
    textTheme: TextTheme(
      displayLarge: largeTitle.copyWith(color: lightTextColor),
      displayMedium: title1.copyWith(color: lightTextColor),
      displaySmall: title2.copyWith(color: lightTextColor),
      headlineLarge: title3.copyWith(color: lightTextColor),
      headlineMedium: headline.copyWith(color: lightTextColor),
      headlineSmall: subhead.copyWith(color: lightTextColor),
      bodyLarge: body.copyWith(color: lightTextColor),
      bodyMedium: callout.copyWith(color: lightTextColor),
      bodySmall: footnote.copyWith(color: lightSecondaryTextColor),
      titleLarge: title3.copyWith(
        color: lightTextColor,
        fontWeight: AppFonts.bold,
      ),
      titleMedium: headline.copyWith(color: lightTextColor),
      titleSmall: footnote.copyWith(color: lightSecondaryTextColor),
      labelLarge: button.copyWith(color: primaryColor),
      labelMedium: button.copyWith(color: lightTextColor, fontSize: 15),
      labelSmall: caption1.copyWith(color: lightSecondaryTextColor),
    ),
    dividerTheme: DividerThemeData(
      color: lightDividerColor,
      thickness: 0.5,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: standardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
    ),
    iconTheme: IconThemeData(color: lightIconColor, size: 24),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: button.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: button,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: button,
        side: BorderSide(color: primaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: systemGray5Light,
      contentTextStyle: body.copyWith(color: lightTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      titleTextStyle: headline.copyWith(
        color: lightTextColor,
        fontWeight: AppFonts.semiBold,
      ),
      contentTextStyle: body.copyWith(color: lightTextColor),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: systemGray5Light,
        borderRadius: BorderRadius.circular(smallCornerRadius),
      ),
      textStyle: caption1.copyWith(color: lightTextColor),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      barBackgroundColor: Colors.white,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: body.copyWith(color: lightTextColor),
        actionTextStyle: button.copyWith(color: primaryColor),
        navTitleTextStyle: navTitle.copyWith(color: lightTextColor),
        navLargeTitleTextStyle: largeTitle.copyWith(color: lightTextColor),
        navActionTextStyle: button.copyWith(color: primaryColor),
        tabLabelTextStyle: tabBar.copyWith(color: lightIconColor),
        dateTimePickerTextStyle: body.copyWith(color: lightTextColor),
      ),
    ),
  );

  // Dark Theme (following iOS standards)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    canvasColor: darkBackgroundColor,
    shadowColor: darkCardShadowColor,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      error: darkErrorColor,
      onError: Colors.white,
      surface: darkCardColor,
      onSurface: darkTextColor,
      primaryContainer: darkPrimaryColorVariant,
      onPrimaryContainer: Colors.white,
      secondaryContainer: accentDarkColor,
      onSecondaryContainer: Colors.white,
      surfaceContainerHighest: darkSurfaceColor,
      onSurfaceVariant: darkSecondaryTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkCardColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: navTitle.copyWith(color: darkTextColor),
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkIconColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: tabBar.copyWith(color: primaryColor),
      unselectedLabelStyle: tabBar.copyWith(color: darkIconColor),
    ),
    textTheme: TextTheme(
      displayLarge: largeTitle.copyWith(color: darkTextColor),
      displayMedium: title1.copyWith(color: darkTextColor),
      displaySmall: title2.copyWith(color: darkTextColor),
      headlineLarge: title3.copyWith(color: darkTextColor),
      headlineMedium: headline.copyWith(color: darkTextColor),
      headlineSmall: subhead.copyWith(color: darkTextColor),
      bodyLarge: body.copyWith(color: darkTextColor),
      bodyMedium: callout.copyWith(color: darkTextColor),
      bodySmall: footnote.copyWith(color: darkSecondaryTextColor),
      titleLarge: title3.copyWith(
        color: darkTextColor,
        fontWeight: AppFonts.bold,
      ),
      titleMedium: headline.copyWith(color: darkTextColor),
      titleSmall: footnote.copyWith(color: darkSecondaryTextColor),
      labelLarge: button.copyWith(color: primaryColor),
      labelMedium: button.copyWith(color: darkTextColor, fontSize: 15),
      labelSmall: caption1.copyWith(color: darkSecondaryTextColor),
    ),
    dividerTheme: DividerThemeData(
      color: darkDividerColor,
      thickness: 0.5,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: modalElevation,
      shadowColor: darkCardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
    ),
    iconTheme: IconThemeData(color: darkIconColor, size: 24),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: button.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: button,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: button,
        side: BorderSide(color: primaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceColor,
      contentTextStyle: body.copyWith(color: darkTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      titleTextStyle: headline.copyWith(
        color: darkTextColor,
        fontWeight: AppFonts.semiBold,
      ),
      contentTextStyle: body.copyWith(color: darkTextColor),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: darkSurfaceColor,
        borderRadius: BorderRadius.circular(smallCornerRadius),
      ),
      textStyle: caption1.copyWith(color: darkTextColor),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      barBackgroundColor: darkCardColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: body.copyWith(color: darkTextColor),
        actionTextStyle: button.copyWith(color: primaryColor),
        navTitleTextStyle: navTitle.copyWith(color: darkTextColor),
        navLargeTitleTextStyle: largeTitle.copyWith(color: darkTextColor),
        navActionTextStyle: button.copyWith(color: primaryColor),
        tabLabelTextStyle: tabBar.copyWith(color: darkIconColor),
        dateTimePickerTextStyle: body.copyWith(color: darkTextColor),
      ),
    ),
  );
}

/// Custom CupertinoButton theming
class CupertinoButtonTheme extends ThemeExtension<CupertinoButtonTheme> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  CupertinoButtonTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
  });

  @override
  ThemeExtension<CupertinoButtonTheme> copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? textColor,
  }) {
    return CupertinoButtonTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  ThemeExtension<CupertinoButtonTheme> lerp(
    ThemeExtension<CupertinoButtonTheme>? other,
    double t,
  ) {
    if (other is! CupertinoButtonTheme) {
      return this;
    }
    return CupertinoButtonTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}
