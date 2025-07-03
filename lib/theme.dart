import 'package:flutter/material.dart';
import 'package:oryn/index.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static MyTheme get currentTheme => GetIt.I<MyTheme>();
  static ThemeMode get themeMode => GetIt.I<MyTheme>().currentTheme();

  static ThemeData lightTheme({
    required BuildContext context,
  }) {
    final accentColor = currentTheme.currentColor();
    final borderRadius = BorderRadius.circular(7.0);
    final greyColor = Colors.grey[800] ?? Colors.grey;
    final lightGreyColor = Colors.grey[600] ?? Colors.grey;

    return ThemeData(
      useMaterial3: false,
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: accentColor,
        cursorColor: accentColor,
        selectionColor: accentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: accentColor),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      disabledColor: lightGreyColor,
      brightness: Brightness.light,
      progressIndicatorTheme:
          const ProgressIndicatorThemeData().copyWith(color: accentColor),
      iconTheme: IconThemeData(
        color: greyColor,
        opacity: 1.0,
        size: 24.0,
      ),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: greyColor,
            brightness: Brightness.light,
            secondary: accentColor,
          ),
      tabBarTheme: TabBarThemeData(indicatorColor: accentColor),
    );
  }

  static ThemeData darkTheme({
    required BuildContext context,
  }) {
    final accentColor = currentTheme.currentColor();
    final canvasColor = currentTheme.getCanvasColor();
    final cardColor = currentTheme.getCardColor();
    final borderRadius = BorderRadius.circular(7.0);

    return ThemeData(
      useMaterial3: false,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: accentColor,
        cursorColor: accentColor,
        selectionColor: accentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: accentColor),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        color: canvasColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      canvasColor: canvasColor,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData().copyWith(color: accentColor),
      iconTheme: const IconThemeData(
        color: Colors.white,
        opacity: 1.0,
        size: 24.0,
      ),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.white,
            secondary: accentColor,
            brightness: Brightness.dark,
          ),
      dialogTheme: DialogThemeData(backgroundColor: cardColor),
      tabBarTheme: TabBarThemeData(indicatorColor: accentColor),
    );
  }
}
