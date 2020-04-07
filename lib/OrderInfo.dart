import 'dart:convert';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/Transactions.dart';

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

  Future<bool> _verify() async { //Do verification before getting order info

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

      if(loginStatus == 'store') { //If verification is successful get list of products
        var map = new Map<String, dynamic>();
        map['id'] = 'S001';
        map['type'] = 'products';

        print('This is ' + storeId);

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

  Future<void> _getUserData() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString('id');
    storeName = prefs.getString('name');
    storeStatus = prefs.getString('status');
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
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[

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
                              )
                          ));
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
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: args.products.length,
                                                  itemBuilder: (BuildContext context,
                                                      int index) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          productsNameList[
                                                          productsList.indexOf(args
                                                              .products[index])],
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .title,
                                                        ),
                                                        Text(
                                                          args.quantities[index]
                                                              .toString(),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .title,
                                                        ),
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
                                      //Padding(
                                      //  padding: const EdgeInsets.only(top: 24.0),
                                      //    child:
                                      //    SizedBox(
                                      //        width: double.infinity,
                                      //        height: 50.0,
                                      //        child: RaisedButton(
                                      //          child: Text("Reverse Transaction", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                      //          onPressed: () {
                                      //            if(args.status == 'Approved') {
                                      //              _reverseTransaction(
                                      //                  args.time,
                                      //                  args.userName,
                                      //                  args.userId,
                                      //                  args.orderId,
                                      //                  args.amount);
                                      //            } else if (args.status == 'Reversed') {
                                      //              Scaffold.of(context).showSnackBar(SnackBar(
                                      //                content: Text("Transaction already reversed"),
                                      //              ));
                                      //            }
                                      //          },
                                      //        )
                                      //    )
                                      //)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ));
                  }
                })

            ]
        )
        );
  }
}
