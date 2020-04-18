import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'Order.dart';
import 'Product.dart';

class AppState with ChangeNotifier {
  AppState();

  var _jsonResponseStore;
  List<dynamic> _strings = [];
  List<Order> users = [];
  List<Product> products = [];
  bool _isFetchingStore = false;

  var quantities = [];
  var quantitiesString = [];

  bool _isFetchingProducts = false;

  bool get isFetchingStore => _isFetchingStore;
  bool get isFetchingProducts => _isFetchingProducts;

  var storeId;
  var storeSecret;


  Future<List<String>> getShopInfo() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _getShopInfo();
  }

  Future<List<String>> refreshShopInfo() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _refreshShopInfo();
  }

  Future<List<String>> getShopHistory() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _getShopHistory();
  }

  Future<List<String>> refreshShopHistory() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _refreshShopHistory();
  }

  Future<List<Product>> getProducts() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _getProducts();
  }

  Future<List<Product>> refreshProducts() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

    _refreshProducts();
  }

  Future<List<Product>> _getProducts() async {
    //Get list of products
    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
      await Dio().post(Home.serverUrl + "process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'store') {

        _isFetchingProducts = true;

        var map = new Map<String, dynamic>();
        map['id'] = storeId; //change to storeId later
        map['type'] = 'products';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response =
          await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          products = [];

          for (var i in jsonData) {
            Product product =
            Product(i["id"], i["name"], double.parse(i["price"]));

            quantities.add(0);
            quantitiesString.add('0');

            products.add(product);
          }

          _isFetchingProducts = false;
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

  Future<List<Product>> _refreshProducts() async {
    //Get list of products
    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
      await Dio().post(Home.serverUrl + "process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'store') {

        _isFetchingProducts = true;
        notifyListeners();

        var map = new Map<String, dynamic>();
        map['id'] = storeId; //change to storeId later
        map['type'] = 'products';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response =
          await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          products = [];
          quantities = [];
          quantitiesString = [];

          for (var i in jsonData) {
            Product product =
            Product(i["id"], i["name"], double.parse(i["price"]));

            quantities.add(0);
            quantitiesString.add('0');

            products.add(product);
          }

          _isFetchingProducts = false;
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

  Future<List<Order>> _getShopHistory() async { //Do verification before getting list of transactions

    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response = await Dio().post(Home.serverUrl + "process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'store') { //If verification is successful

        _isFetchingStore = true;
        notifyListeners();

        var map = new Map<String, dynamic>();
        map['id'] = storeId; //change to storeId later
        map['type'] = 'transactionhistory';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          users = [];

          for (var i in jsonData) {
            Order user = Order(
                int.parse(i["id"]), i["status"], double.parse(i["amount"]), i["time"],
                i["user"]["id"], i["user"]["name"], i["products"], i["amounts"]);

            users.add(user);
          }

          _isFetchingStore = false;
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

  Future<List<Order>> _refreshShopHistory() async { //Do verification before getting list of transactions

    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response = await Dio().post(Home.serverUrl + "process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'store') { //If verification is successful

        _isFetchingStore = true;
        notifyListeners();

        var map = new Map<String, dynamic>();
        map['id'] = storeId; //change to storeId later
        map['type'] = 'transactionhistory';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          users = [];

          for (var i in jsonData) {
            Order user = Order(
                int.parse(i["id"]), i["status"], double.parse(i["amount"]), i["time"],
                i["user"]["id"], i["user"]["name"], i["products"], i["amounts"]);

            users.add(user);
          }

          _isFetchingStore = false;
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

  Future<List<String>> _getShopInfo() async {
    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    _isFetchingStore = true;

    try {
      Response response =
      await Dio().post(Home.serverUrl + "process.php", data: loginData);
      _jsonResponseStore  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResponseStore['name']);
      _strings.add(_jsonResponseStore['balance'].toString());

      _isFetchingStore = false;
      notifyListeners();

    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> _refreshShopInfo() async {
    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    _isFetchingStore = true;
    notifyListeners();

    try {
      Response response =
      await Dio().post(Home.serverUrl + "process.php", data: loginData);
      _jsonResponseStore  = json.decode(response.toString());

      _strings = [];

      _strings.add(_jsonResponseStore['name']);
      _strings.add(_jsonResponseStore['balance'].toString());

      _isFetchingStore = false;
      notifyListeners();

    } catch (e) {
      print(e);
    }
  }

  void resetProductQuantities() {
    quantities = [];
    quantitiesString = [];
    for (var i in products) {
      quantities.add(0);
      quantitiesString.add('0');
    }
  }

  List<dynamic> getUserResponseJson() {
    if(_jsonResponseStore != null) {
      return _strings;
    }
    return null;
  }

  List<dynamic> getProductsJson() {
    if(products != null) {
      return products;
    }
    return null;
  }

  List<dynamic> getProductQuantities() {
    if(products != null) {
      return quantities;
    }
    return null;
  }

  List<dynamic> getProductQuantitiesString() {
    if(products != null) {
      return quantitiesString;
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