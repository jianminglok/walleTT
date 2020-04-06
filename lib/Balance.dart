import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> _sharedStrings;

class Balance extends StatefulWidget {
  Balance({Key key}) : super(key: key);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  var productsNameList = [];
  var productsList = [];

  Future _future;

  Future _future2;

  var agentId;
  var agentSecret;

  Future _verify(String userId) async {
    //Do verification before getting order info

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'checkbalance';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'ok') {
        //If verification is successful get list of products
        var map = new Map<String, dynamic>();
        map['id'] = userId;
        map['type'] = 'checkbalance';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio()
              .post("http://10.0.88.178/process.php", data: formData);

          var jsonData = json.decode(response.toString());

          List<String> strings = [];

          strings.add(jsonData['name']);
          strings.add(jsonData['balance'].toString());
          strings.add(jsonData['remark']);

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

  void _scan() async {
    String userId = await scan();
    setState(() {
      _future2 = _verify(userId);
    });
  }

  static Future<String> scan() async {
    //Scan QR code
    try {
      return await BarcodeScanner.scan();
    } catch (e) {
      if (e is PlatformException) {
        print("Camera permission not obtained!");
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
                    return FutureBuilder(
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
                                                  _scan();
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
                              return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(26.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(top: 24.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Name",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subhead
                                                          .copyWith(color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[0],
                                                    style:
                                                    Theme.of(context).textTheme.title,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 24.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Status',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subhead
                                                          .copyWith(color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    StringUtils.capitalize(snapshot.data[2]),
                                                    style:
                                                    Theme.of(context).textTheme.title,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 24.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Balance (RM)",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subhead
                                                          .copyWith(color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    FlutterMoneyFormatter(amount: double.parse(snapshot.data[1])).output.nonSymbol,
                                                    style: TextStyle(
                                                        fontSize: 40.0,
                                                        fontWeight: FontWeight.w800),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 48.0),
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
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                          }
                        }); //Display card when loaded
                }
              })
        ]));
  }
}
