import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';
import 'package:walleTT/tabsContainer.dart';

import 'Order.dart';
import 'barcode_scanner.dart';
import 'package:http/http.dart' as http;

class Transactions extends StatefulWidget {

  Transactions({Key key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  bool _isLoading = true;
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  Future<List<Order>> _future;

  Future<List<Order>> _getUsers() async {
    //Get list of users from server
    var data = await http.get(
        "https://my-json-server.typicode.com/jianminglok/wallettJson/order");

    var jsonData = json.decode(data.body);

    List<Order> users = [];

    for (var i in jsonData) {
      Order user = Order(
          int.parse(i["id"]), i["status"], double.parse(i["amount"]), i["time"],
          int.parse(i["user"]["id"]), i["user"]["name"]);

      users.add(user);
    }
    return users;
  }

  Future<List<Order>> _refresh() async { //Refresh list of users from server
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
        title: new Center(child: Text("Transactions")),
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
                        onRefresh: _refresh,
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
                                          if(snapshot.data[index].status == 'approved') {
                                            _reverseTransaction(
                                                snapshot.data[index].time,
                                                snapshot.data[index].userName,
                                                snapshot.data[index].userId,
                                                snapshot.data[index].orderId,
                                                snapshot.data[index].amount);
                                          } else if (snapshot.data[index].status == 'reversed') {
                                              Scaffold.of(context).showSnackBar(SnackBar(
                                                content: Text("Transaction already reversed"),
                                              ));
                                          }
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
                                                    snapshot.data[index].userName + ' (' + snapshot.data[index].userId.toString() + ')',
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
                                                    snapshot.data[index].amount.toStringAsFixed(2),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'Balance: RM20.00',
                                                    style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18.0),
                                                  ),
                                                ],
                                              ),
                                              Chip(
                                                backgroundColor: snapshot.data[index].status == 'approved' ? Color(0xff03da9d).withAlpha(30) : Theme.of(context).primaryColor.withAlpha(30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                ),
                                                label: Text(
                                                  StringUtils.capitalize(snapshot.data[index].status),
                                                  style: TextStyle(color:
                                                      snapshot.data[index].status == 'approved' ? Color(0xff03da9d) : Theme.of(context).primaryColor),
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

  void _reverseTransaction(String time, String userName, int userId, int orderId, double amount) {
    String displayAmount =
        FlutterMoneyFormatter(amount: amount).output.nonSymbol;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: 450,
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
                  Text(
                      'Reverse Transaction?',
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
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(time)),
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
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        userName + ' (' + userId.toString() + ')' ,
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
                          "ID",
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
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
                          "Amount (RM)",
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        displayAmount,
                        style: TextStyle(fontSize: 60.0, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Cancel", style: TextStyle(fontSize: 18.0)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child:
                        Text("Reverse", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
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
            i["time"], int.parse(i["user"]["id"]), i["user"]["name"]);
        users.add(user);
      }
    }

    _currentPage++;
    return users;
  }
}