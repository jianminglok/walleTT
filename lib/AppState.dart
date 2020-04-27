import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'Transaction.dart';

class AppState with ChangeNotifier {
  AppState();

  var _jsonResonseUser;
  List<dynamic> _strings = [];
  List<Transaction> users = [];
  bool _isFetchingUser = false;

  bool get isFetchingUser => _isFetchingUser;

  var agentId;
  var agentSecret;

  Future<List<String>> getUserData() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _getUserInfo();
  }

  Future<List<String>> refreshUserData() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _refreshUserInfo();
  }

  Future<List<String>> getUserHistory() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _getUserHistory();
  }

  Future<List<String>> refreshUserHistory() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    _refreshUserHistory();
  }

  Future<List<Transaction>> _getUserHistory() async { //Do verification before getting list of transactions

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'topuphistory';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response = await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'agent') { //If verification is successful

        _isFetchingUser = true;

        var map = new Map<String, dynamic>();
        map['id'] = agentId; //change to storeId later
        map['type'] = 'topuphistory';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          users = [];

          for (var i in jsonData) {
            Transaction user = Transaction(
                int.parse(i["id"]), double.parse(i["amount"]), i["time"],
                i["user"]["id"], i["user"]["name"], i["remark"], i["cleared"]);

            users.add(user);
          }

          _isFetchingUser = false;
          notifyListeners();
        } catch (e) {
          print(e);
        }
      } else {
        status = loginStatus;
      }

    } catch (e) {
      print(e);
    }
  }

  Future<List<Transaction>> _refreshUserHistory() async { //Do verification before getting list of transactions

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response = await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'agent') { //If verification is successful

        _isFetchingUser = true;
        notifyListeners();

        var map = new Map<String, dynamic>();
        map['id'] = agentId; //change to storeId later
        map['type'] = 'topuphistory';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          users = [];

          for (var i in jsonData) {
            Transaction user = Transaction(
                int.parse(i["id"]), double.parse(i["amount"]), i["time"],
                i["user"]["id"], i["user"]["name"], i["remark"], i["cleared"]);

            users.add(user);
          }

          _isFetchingUser = false;
          notifyListeners();
        } catch (e) {
          print(e);
        }
      } else {
        status = loginStatus;
      }

    } catch (e) {
      print(e);
    }
  }

  Future<List<dynamic>> _getUserInfo() async {
    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    _isFetchingUser = true;

    try {
      Response response =
      await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      _jsonResonseUser  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResonseUser['name']);
      _strings.add(_jsonResonseUser['balance']);

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
      await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      _jsonResonseUser  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResonseUser['name']);
      _strings.add(_jsonResonseUser['balance']);

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

  List<dynamic> getUserHistoryJson() {
    if(users != null) {
      return users;
    }
    return null;
  }
}