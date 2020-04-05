import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';
import 'package:walleTT/tabsContainer.dart';

import 'Order.dart';
import 'OrderInfo.dart';
import 'barcode_scanner.dart';
import 'package:http/http.dart' as http;

int orderLength;
Future<List<Order>> _future;

class Transactions extends StatefulWidget {

  Transactions({Key key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();

  void checkOrderLength() async {
    _TransactionsState().refreshOrder();
  }

}

class _TransactionsState extends State<Transactions> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  bool _isLoading = true;
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  Future<List<Order>> _getUsers() async {
    //Get list of users from server

    var map = new Map<String, dynamic>();
    map['id'] = 'S001';
    map['type'] = 'transactionhistory';

    FormData formData = new FormData.fromMap(map);

    try {
      Response response = await Dio().post("http://10.0.88.178/process.php", data: formData);
      print(response);

      var jsonData = json.decode(response.toString());

      print(jsonData);

      List<Order> users = [];

      for (var i in jsonData) {
        Order user = Order(
            int.parse(i["id"]), i["status"], double.parse(i["amount"]), i["time"],
            i["user"]["id"], i["user"]["name"]);

        users.add(user);
      }
      return users;
    } catch (e) {
      print(e);
    }
  }


  Future<List<Order>> refreshOrder() async { //Refresh list of users from server
    setState(() {
      _future = _getUsers();
    });
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _future = _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: new Text("Transactions"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FutureBuilder<List<Order>>(
              future: _future,
              builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting: //Display progress circle while loading
                  return Container(
                      padding: EdgeInsets.only(top: 50.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )
                  );
                default: //Display card when loaded
                  return Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                      child:
                      RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: refreshOrder,
                        child:
                          ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) =>
                            Container(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(20, 1.25, 20, 1.25),
                                  child: SizedBox(
                                    height: 165,
                                    width: double.infinity,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onLongPress: () {
                                        },
                                        onTap: () {
                                          Navigator.push( //Open QR Scanner
                                            context,
                                            MaterialPageRoute(builder: (context) => OrderInfo(),
                                              settings: RouteSettings(
                                                arguments: OrderInfoArguments(
                                                    snapshot.data[index].time,
                                                    snapshot.data[index].userName,
                                                    snapshot.data[index].userId,
                                                    snapshot.data[index].orderId,
                                                    snapshot.data[index].amount,
                                                    snapshot.data[index].status),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].userName + ' (' + snapshot.data[index].userId + ')',
                                                    style: Theme.of(context).textTheme.subhead,
                                                  ),
                                                  Text(
                                                    'Order ID: ' + snapshot.data[index].orderId.toString(),
                                                    style: Theme.of(context).textTheme.subhead,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    'RM ' + snapshot.data[index].amount.toStringAsFixed(2),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Chip(
                                                backgroundColor: snapshot.data[index].status == 'Approved' ? Color(0xff03da9d).withAlpha(30) : Theme.of(context).primaryColor.withAlpha(30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                ),
                                                label: Text(
                                                  StringUtils.capitalize(snapshot.data[index].status),
                                                  style: TextStyle(color:
                                                      snapshot.data[index].status == 'Approved' ? Color(0xff03da9d) : Theme.of(context).primaryColor),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data[index].time,
                                                      style: Theme.of(context).textTheme.body1,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                              ),
                        )
                      )
                          )
                      )
                    )
                  );
                }
              }
              ),
            ],
          )
    );
  }

  _test(index, context) {
    Navigator.push( //Open QR Scanner
      context,
      MaterialPageRoute(builder: (context) => BarcodeScanner(),
        settings: RouteSettings(
          arguments: index,
        ),
      ),
    );
  }
}

class OrderInfoArguments {
  final String time;
  final String userName;
  final String userId;
  final int orderId;
  final double amount;
  final String status;

  OrderInfoArguments(this.time, this.userName, this.userId, this.orderId, this.amount, this.status);
}

class _ItemFetcher {
  final _count = 6;
  final _itemsPerPage = 5;
  int _currentPage = 0;

  Future<List<Order>> _getUsers() async { //Get list of users from server
    var data = await http.get("https://my-json-server.typicode.com/jianminglok/wallettJson/order");

    var jsonData = json.decode(data.body);

    List<Order> users = [];

    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);

    for (var i in jsonData) {
      if(i < n) {
        Order user = Order(
            int.parse(i["id"]), i["status"], double.parse(i["amount"]),
            i["time"], i["user"]["id"], i["user"]["name"]);
        users.add(user);
      }
    }

    _currentPage++;
    return users;
  }
}