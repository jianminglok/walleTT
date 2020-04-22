import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Transactions.dart';

import 'AppState.dart';
import 'Home.dart';

class OrderInfo extends StatefulWidget {
  OrderInfo({Key key}) : super(key: key);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  var productsNameList = [];
  var productsList = [];

  Future<bool> _future;

  var storeId;
  var storeName;
  var storeStatus;
  var storeSecret;

  var transStatus;
  bool reversed = false;

  Future<String> _reverseResult;
  bool reversing = false;

  Future<bool> _verify() async {
    //Do verification before getting order info

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
        //If verification is successful get list of products
        var map = new Map<String, dynamic>();
        map['id'] = storeId;
        map['type'] = 'products';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response =
              await Dio().post(Home.serverUrl + "process.php", data: formData);

          var jsonData = json.decode(response.toString());

          for (var i in jsonData) {
            productsNameList.add(i["name"]);
            productsList.add(i["id"]);
          }

          return true;
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

  void _refreshBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshShopInfo();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshShopHistory();
  }

  Future<String> _reverseTransaction(userId, orderId, time) async {
    //Do verification when submitting payment

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
        //If verification successful

        var map = new Map<String, dynamic>();
        map['id'] = orderId.toString();
        map['time'] = time;
        map['userId'] = userId;
        map['type'] = 'reverse';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response =
              await Dio().post(Home.serverUrl + "process.php", data: formData);
          var jsonData = json.decode(response.toString());

          String reverseStatus = jsonData["status"];

          if (reverseStatus == 'Successful') {
            _refreshBalance();
            _refreshHistory();
            setState(() {
              reversed = true;
              transStatus = 'Reversed';
            });
          }

          return reverseStatus;
        } catch (e) {}
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
    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');

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
    final OrderInfoArguments args = ModalRoute.of(context).settings.arguments;

    transStatus = args.status;
    if (args.status == 'Reversed') {
      setState(() {
        reversed = true;
      });
    }

    String displayAmount =
        FlutterMoneyFormatter(amount: args.amount).output.nonSymbol;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Order Info"),
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
                                Text('Order ID: ' + args.orderId.toString(),
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
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(DateTime.parse(args.time)),
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
                                        "Products",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(color: Colors.black54),
                                      ),
                                      Text(
                                        "Quantity",
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
                                    Expanded(
                                        child: ListView.separated(
                                            separatorBuilder: (context, index) => Divider(
                                              color: Colors.black54,
                                            ),
                                            shrinkWrap: true,
                                            itemCount: args.products.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      productsNameList[
                                                          productsList.indexOf(
                                                              args.products[
                                                                  index])],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .title,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      args.quantities[index]
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .title,
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  )
                                                ],
                                              );
                                            }))
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
                                                !reversed
                                            ? RaisedButton(
                                                child: Text(
                                                    "Reverse Transaction",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0)),
                                                onPressed: () {
                                                  if (transStatus ==
                                                          'Approved' &&
                                                      !reversed) {
                                                    _confirmReverse(
                                                        args.userId,
                                                        args.orderId,
                                                        args.amount,
                                                        args.products,
                                                        args.quantities,
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

  void _confirmReverse(userId, orderId, _amount, products, quantities, time,
      BuildContext context) async {
    if (double.parse(_amount.toString()) > 0) {
      String displayAmount =
          FlutterMoneyFormatter(amount: double.parse(_amount.toString()))
              .output
              .nonSymbol;
      if (userId != null) {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        Text('Confirm Reverse?',
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
                                "Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
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
                                "Order ID",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              orderId.toString(),
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
                                "Product",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                              Text(
                                "Quantity",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: ListView.separated(
                                    separatorBuilder: (context, index) => Divider(
                                      color: Colors.black54,
                                    ),
                                    shrinkWrap: true,
                                    itemCount: products.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              productsNameList[productsList
                                                  .indexOf(products[index])],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              quantities[index].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      );
                                    }))
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
                                    .copyWith(color: Colors.black54),
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
                                  _reverseResult = _reverseTransaction(
                                      userId, orderId, time);
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
                                                color: Colors.white,
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
                                                                        'Successful'
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
