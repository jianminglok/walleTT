import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  AppState();

  var _jsonResonseUser;
  List<dynamic> _strings = [];
  bool _isFetchingUser = false;

  bool get isFetchingUser => _isFetchingUser;

  var agentId;
  var agentSecret;

  Future<List<String>> getUserData() async {
    //Get store id etc
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _getUserInfo();
  }

  Future<List<String>> refreshUserData() async {
    //Get store id etc
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _refreshUserInfo();
  }

  Future<List<dynamic>> _getUserInfo() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    _isFetchingUser = true;

    try {
      Response response =
      await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      _jsonResonseUser  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResonseUser['name']);
      _strings.add(_jsonResonseUser['balance']);

      print(_jsonResonseUser['balance']);

      _isFetchingUser = false;
      notifyListeners();

    } catch (e) {
      print(e);
    }
  }

  Future<List<dynamic>> _refreshUserInfo() async {

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    _isFetchingUser = true;
    notifyListeners();

    try {
      Response response =
      await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      _jsonResonseUser  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResonseUser['name']);
      _strings.add(_jsonResonseUser['balance']);

      print(_jsonResonseUser['balance']);

      _isFetchingUser = false;
      notifyListeners();

    } catch (e) {
      print(e);
    }
  }

  List<dynamic> getUserResponseJson() {
   if(_jsonResonseUser != null) {
     return _strings;
   }
   return null;
  }
}