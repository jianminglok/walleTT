import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Home.dart';
import 'package:walleTT/colors.dart';

import 'Login.dart';

final darkTheme = ThemeData.dark().copyWith(
  textTheme: ThemeData.dark().textTheme.apply(
    fontFamily: 'Rubik',
  ).merge(
    TextTheme(
      display1: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      display2: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      button: TextStyle(color: Colors.white),
    ),
  ),
  primaryColor: const Color(0xFFef4c3c),
  accentColor: const Color(0xFFd84b3d),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(8),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(style: BorderStyle.none),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFFef4c3c),
    textTheme: ButtonTextTheme.normal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
);

final lightTheme = ThemeData(
  // This is the theme of your application.
  //
  // Try running your application with "flutter run". You'll see the
  // application has a blue toolbar. Then, without quitting the app, try
  // changing the primarySwatch below to Colors.green and then invoke
  // "hot reload" (press "r" in the console where you ran "flutter run",
  // or simply save your changes to "hot reload" in a Flutter IDE).
  // Notice that the counter didn't reset back to zero; the application
  // is not restarted.
  primarySwatch: Colors.red,
  primaryColor: const Color(0xFFef4c3c),
  accentColor: const Color(0xFFd84b3d),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[50],
  appBarTheme: AppBarTheme(color: Colors.white),
  fontFamily: 'Rubik',
  textTheme: TextTheme(
    display1: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    display2: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    button: TextStyle(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(8),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(style: BorderStyle.none),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFFef4c3c),
    textTheme: ButtonTextTheme.normal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
);

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

Future<void> main() async { //If user is logged in go to Home
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var name = prefs.getString('name');
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
          child: MaterialApp(home: name == null ? Login() : Home())
      ),
    );
  });
}