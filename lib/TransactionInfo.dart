import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Transactions.dart';

import 'AppState.dart';
import 'Home.dart';
import 'main.dart';

class TransactionInfo extends StatefulWidget {
  TransactionInfo({Key key}) : super(key: key);

  @override
  _TransactionInfoState createState() => _TransactionInfoState();
}

class _TransactionInfoState extends State<TransactionInfo> {
  var productsNameList = [];
  var productsList = [];

  Future<bool> _future;

  var agentId;
  var agentSecret;

  var topupId;
  var topupTime;

  var _darkTheme = false;

  var transStatus;
  bool reversed = false;

  Future<String> _reverseResult;
  bool reversing = false;

  Future<bool> _verify() async {
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
        return true;
      } else {
        status = loginStatus;
      }
    } catch (e) {
      print(e);
    }
  }

  void _refreshBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserData();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserHistory();
  }

  Future<String> _reverseTransaction(topupId) async {
    //Do verification when submitting payment

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
        //If verification successful

        var map = new Map<String, dynamic>();
        map['id'] = topupId;
        map['time'] = topupTime;
        map['agentId'] = agentId;
        map['type'] = 'topUp/RegistrationReversal';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response =
              await Dio().post(Home.serverUrl + "process.php", data: formData);
          var jsonData = json.decode(response.toString());

          String reverseStatus = jsonData["status"];

          if (reverseStatus == 'Success') {
            _refreshBalance();
            _refreshHistory();
            setState(() {
              reversed = true;
              transStatus = 'Voided';
            });
          }
          return reverseStatus;
        } catch (e) {
          print(e);
        }
      } else {
        return loginStatus;
      }
      return status;
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getUserData() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    setState(() {
      _future = _verify();
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionInfoArguments args =
        ModalRoute.of(context).settings.arguments;

    String displayAmount =
        FlutterMoneyFormatter(amount: args.amount).output.nonSymbol;

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    topupId = args.topupId;
    topupTime = args.time;

    transStatus = args.reversed;

    if (args.reversed == 'Reversed') {
      setState(() {
        reversed = true;
      });
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Transaction Info"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                Widget>[
          FutureBuilder<bool>(
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
                  default: //Display card when loaded
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
                                Text(
                                    'Transaction ID: ' +
                                        args.topupId.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline
                                        .copyWith(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Time",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                color: _darkTheme
                                                    ? Colors.white54
                                                    : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      args.time,
                                      style: Theme.of(context).textTheme.title,
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
                                        "Name",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                color: _darkTheme
                                                    ? Colors.white54
                                                    : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      args.userName + ' (' + args.userId + ')',
                                      style: Theme.of(context).textTheme.title,
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
                                        "Type",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                color: _darkTheme
                                                    ? Colors.white54
                                                    : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      StringUtils.capitalize(args.remark),
                                      style: Theme.of(context).textTheme.title,
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
                                        "Status",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                color: _darkTheme
                                                    ? Colors.white54
                                                    : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      StringUtils.capitalize(args.cleared),
                                      style: Theme.of(context).textTheme.title,
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
                                        "Amount (RM)",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                color: _darkTheme
                                                    ? Colors.white54
                                                    : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      displayAmount,
                                      style: TextStyle(
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: SizedBox(
                                        width: double.infinity,
                                        height: 50.0,
                                        child: transStatus == 'Approved' &&
                                                !reversed &&
                                                args.cleared != 'cleared' &&
                                                DateTime.now()
                                                        .difference(
                                                            DateTime.parse(
                                                                args.time))
                                                        .inMinutes <
                                                    20
                                            ? RaisedButton(
                                                child: Text("Void Topup",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0)),
                                                onPressed: () {
                                                  if (transStatus == 'Approved' &&
                                                      !reversed &&
                                                      args.cleared !=
                                                          'cleared' &&
                                                      DateTime.now()
                                                              .difference(
                                                                  DateTime.parse(
                                                                      args.time))
                                                              .inMinutes <
                                                          20) {
                                                    _confirmReverse(
                                                        args.userName,
                                                        args.userId,
                                                        args.topupId,
                                                        args.amount,
                                                        args.time,
                                                        context);
                                                  }
                                                })
                                            : Container()))
                              ],
                            ),
                          ),
                        )
                      ],
                    ));
                }
              })
        ]));
  }

  void _confirmReverse(
      userName, userId, transId, _amount, time, BuildContext context) async {
    if (double.parse(_amount.toString()) > 0) {
      String displayAmount =
          FlutterMoneyFormatter(amount: double.parse(_amount.toString()))
              .output
              .nonSymbol;
      if (transId != null) {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: _darkTheme ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Confirm Void?',
                            style: Theme.of(context)
                                .textTheme
                                .headline
                                .copyWith(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Transaction ID",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              transId.toString(),
                              style: Theme.of(context).textTheme.title,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              time,
                              style: Theme.of(context).textTheme.title,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              userName + ' (' + userId + ')',
                              style: Theme.of(context).textTheme.title,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Amount (RM)",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              displayAmount,
                              style: TextStyle(
                                  fontSize: 60.0, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            FlatButton(
                              child: Text("Cancel",
                                  style: TextStyle(fontSize: 18.0)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            RaisedButton(
                              child: Text("Confirm",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0)),
                              onPressed: () {
                                if (reversing == false) {
                                  _reverseResult = _reverseTransaction(transId);
                                  Navigator.pop(context);

                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      isDismissible: false,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return Wrap(children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: _darkTheme
                                                    ? Colors.grey.shade800
                                                    : Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(18),
                                                  topRight: Radius.circular(18),
                                                ),
                                              ),
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      26.0),
                                                  child: Center(
                                                      child: FutureBuilder<
                                                              String>(
                                                          future:
                                                              _reverseResult,
                                                          builder: (context,
                                                              snapshot) {
                                                            switch (snapshot
                                                                .connectionState) {
                                                              case ConnectionState
                                                                  .none:
                                                              case ConnectionState
                                                                  .waiting: //Display progress circle while loading
                                                                return Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: <
                                                                        Widget>[
                                                                      Center(
                                                                          child: Center(
                                                                              child: SpinKitDoubleBounce(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                        size:
                                                                            50.0,
                                                                      )))
                                                                    ]);
                                                              default: //Display card when loaded
                                                                return snapshot
                                                                            .data ==
                                                                        'Success'
                                                                    ? Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .stretch,
                                                                        mainAxisSize:
                                                                            MainAxisSize
                                                                                .max,
                                                                        children: <
                                                                            Widget>[
                                                                            Center(
                                                                              child: Icon(
                                                                                Icons.check,
                                                                                color: Color(0xff03da9d),
                                                                                size: 60.0,
                                                                              ),
                                                                            ),
                                                                            Center(
                                                                              child: Text(
                                                                                'Successful',
                                                                                style: Theme.of(context).textTheme.title,
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 24.0),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: <Widget>[
                                                                                RaisedButton(
                                                                                  child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      reversing = false;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                )
                                                                              ],
                                                                            )
                                                                          ])
                                                                    : Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .stretch,
                                                                        mainAxisSize:
                                                                            MainAxisSize
                                                                                .max,
                                                                        children: <
                                                                            Widget>[
                                                                            Center(
                                                                              child: Icon(
                                                                                Icons.clear,
                                                                                color: Theme.of(context).primaryColor,
                                                                                size: 60.0,
                                                                              ),
                                                                            ),
                                                                            Center(
                                                                              child: Text(
                                                                                snapshot.data.toString(),
                                                                                style: Theme.of(context).textTheme.title,
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 24.0),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: <Widget>[
                                                                                RaisedButton(
                                                                                  child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      reversing = false;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                )
                                                                              ],
                                                                            )
                                                                          ]);
                                                            }
                                                          }))))
                                        ]);
                                      });
                                } else {
                                  Scaffold.of(context).removeCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Please wait for the previous transaction to finish first"),
                                  ));
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ]);
            });
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please try again"),
        ));
      }
    } else {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Amount must be larger than 0!"),
      ));
    }
  }
}
