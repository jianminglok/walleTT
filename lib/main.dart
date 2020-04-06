import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Home.dart';

import 'Login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var name = prefs.getString('name');
  runApp(MaterialApp(home: name == null ? Login() : Home()));
}