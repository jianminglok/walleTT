import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Transactions.dart';

import 'AppState.dart';
import 'Home.dart';
import 'main.dart';

class Balance extends StatefulWidget {
  Balance({Key key}) : super(key: key);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  var productsNameList = [];
  var productsList = [];

  Future _future;

  Future<List<String>> _future2;

  var agentId;
  var agentSecret;

  var _darkTheme = false;

  Future<List<String>> _verify(String userId) async {
    //Do verification before getting order info

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post(Home.serverUrl + "verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'agent') {
        //If verification is successful get list of products
        var map = new Map<String, dynamic>();
        map['id'] = userId;
        map['type'] = 'checkbalance';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio()
              .post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          List<String> strings = [];

          if (jsonData['status'] == 'User does not exist!') {
            strings.add(jsonData['status']);
          } else {
            strings.add(jsonData['name']);
            strings.add(jsonData['balance'].toString());
            strings.add(jsonData['remark']);
            strings.add(userId);
          }

          return strings;
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

  @override
  void initState() {
    super.initState();
    _future = _getUserData();
  }

  void _scan2() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserData();
  }

  void _scan() async {
    String userId = await scan();
    if(userId != null && userId.isNotEmpty && userId.contains('U') && userId.contains(';')) {
      setState(() {
        _future2 = _verify(userId);
      });
    } else if (userId != null && userId.isNotEmpty && !userId.contains('U') && !userId.contains(';')) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please scan a valid QR code"),
      ));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please try again"),
      ));
    }
  }

  static Future<String> scan() async {
    //Scan QR code
    try {
      return await BarcodeScanner.scan();
    } catch (e) {
      if (e is PlatformException) {
      }
    }
    return null;
  }

  Future<void> _getUserData() async {
    //Get store id, name etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');
  }

  @override
  Widget build(BuildContext context) {

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Check Balance"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                Widget>[
          FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState
                      .waiting: //Display progress circle while loading
                    return Container(
                        child: Center(
                            child: SpinKitDoubleBounce(
                      color: Theme.of(context).primaryColor,
                      size: 50.0,
                    )));
                  default:
                    return FutureBuilder<List<String>>(
                        future: _future2,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Container(
                                  child: Padding(
                                      padding: const EdgeInsets.all(26.0),
                                      child: Center(
                                          child: SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: RaisedButton.icon(
                                                icon: Icon(
                                                  Icons.center_focus_strong,
                                                  color: Colors.white,
                                                ),
                                                label: Text("Scan QR Code",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0)),
                                                onPressed: () {
                                                  setState(() {
                                                    _scan();
                                                  });
                                                },
                                              )))));
                            case ConnectionState
                                .waiting: //Display progress circle while loading
                              return Container(
                                  child: Center(
                                      child: SpinKitDoubleBounce(
                                color: Theme.of(context).primaryColor,
                                size: 50.0,
                              )));
                            default:
                              if (snapshot.data.length == 1) {
                                return Padding(
                                    padding: const EdgeInsets.all(26.0),
                                    child: Column(
                                      children: <Widget>[
                                        Center(
                                          child: Icon(
                                            Icons.clear,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 60.0,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            snapshot.data[0],
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 48.0),
                                            child: SizedBox(
                                                width: double.infinity,
                                                height: 50.0,
                                                child: RaisedButton.icon(
                                                  icon: Icon(
                                                    Icons.center_focus_strong,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text("Scan QR Code",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18.0)),
                                                  onPressed: () {
                                                    _scan();
                                                  },
                                                )))
                                      ],
                                    ));
                              } else {
                                return Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(26.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "ID",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                        color:
                                                        _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[3].split('U')[1].split(';')[0],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Name",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                            color:
                                                            _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[0],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Status',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                            color:
                                                            _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  StringUtils.capitalize(
                                                      snapshot.data[2]),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .title,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Balance (RM)",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                            color:
                                                            _darkTheme ? Colors.white54 : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  FlutterMoneyFormatter(
                                                          amount: double.parse(
                                                              snapshot.data[1]))
                                                      .output
                                                      .nonSymbol,
                                                  style: TextStyle(
                                                      fontSize: 40.0,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24.0),
                                            ),
                                            Container(
                                              child: snapshot.data[2] ==
                                                      'frozen'
                                                  ? Center(
                                                      child: Text(
                                                        'Account is frozen. Please verify user identity and contact administrator if required.',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle,
                                                      ),
                                                    )
                                                  : Container(),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 48.0),
                                                child: SizedBox(
                                                    width: double.infinity,
                                                    height: 50.0,
                                                    child: RaisedButton.icon(
                                                      icon: Icon(
                                                        Icons
                                                            .center_focus_strong,
                                                        color: Colors.white,
                                                      ),
                                                      label: Text(
                                                          "Scan QR Code",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18.0)),
                                                      onPressed: () {
                                                        _scan();
                                                      },
                                                    )))
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                              }
                          }
                        }); //Display card when loaded
                }
              })
        ]));
  }
}
