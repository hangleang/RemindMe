import 'package:codenova_reminders/themes/themes.dart';
import 'package:flutter/material.dart';
 
class AppThemes {
  AppThemes._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: THEMES.first[1],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Kantumruy',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline2: TextStyle(fontSize: 63.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline3: TextStyle(fontSize: 54.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline4: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline5: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline6: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      bodyText1: TextStyle(fontSize: 18.0, fontFamilyFallback: ['ProductSans']),
      bodyText2: TextStyle(fontSize: 14.0, fontFamilyFallback: ['ProductSans']),
      subtitle1: TextStyle(fontSize: 16.0, fontFamilyFallback: ['ProductSans']),
      subtitle2: TextStyle(fontSize: 13.0, fontFamilyFallback: ['ProductSans']),
    ),
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: THEMES.first[1],
    accentColor: THEMES.first[0],
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: THEMES.first[1],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Kantumruy',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline2: TextStyle(fontSize: 63.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline3: TextStyle(fontSize: 54.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline4: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline5: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      headline6: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold, fontFamilyFallback: ['ProductSans']),
      bodyText1: TextStyle(fontSize: 18.0, fontFamilyFallback: ['ProductSans']),
      bodyText2: TextStyle(fontSize: 14.0, fontFamilyFallback: ['ProductSans']),
      subtitle1: TextStyle(fontSize: 16.0, fontFamilyFallback: ['ProductSans']),
      subtitle2: TextStyle(fontSize: 13.0, fontFamilyFallback: ['ProductSans']),
    ),
    backgroundColor: Colors.black87,
    primaryColor: THEMES.first[1],
    accentColor: THEMES.first[0]
  );
}

// class AppThemeNotifier with ChangeNotifier {
//   ThemeData _themeData;
//   int _themeIndex;

//   AppThemeNotifier(this._themeData, this._themeIndex);

//   ThemeData get themeData => this._themeData;
//   int get themeIndex => this._themeIndex;

//   set themeData(ThemeData newThemeData) {
//     this._themeData = newThemeData;
//     notifyListeners();
//   }

//   set themeIndex(int newThemeIndex) {
//     this._themeIndex = newThemeIndex;
//     notifyListeners();
//   }
// }