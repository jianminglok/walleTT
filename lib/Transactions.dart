import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';
import 'package:walleTT/tabsContainer.dart';

import 'User.dart';
import 'barcode_scanner.dart';
import 'package:http/http.dart' as http;

class Transactions extends StatefulWidget {

  Transactions({Key key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  Future<List<User>> _future;

  Future<List<User>> _getUsers() async { //Get list of users from server
    var data = await http.get("https://jsonplaceholder.typicode.com/users");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var i in jsonData) {
      User user = User(i["id"], i["name"], i["email"]);

      users.add(user);
    }
    return users;
  }

  Future<List<User>> _refresh() async { //Refresh list of users from server
    setState(() {
      _future = _getUsers();
    });
  }

  @override
  void initState() {
    super.initState();
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
              FutureBuilder<List<User>>(
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
                        transform: Matrix4.translationValues(0.0, 10.0, 0.0),
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
                                          _reverseTransaction(snapshot.data[index].name, snapshot.data[index].id.toString(), '1');
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
                                                    snapshot.data[index].name,
                                                    style: Theme.of(context).textTheme.subhead,
                                                  ),
                                                  Text(
                                                    'ID: ' + snapshot.data[index].id.toString(),
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
                                                    "Test",
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
                                                backgroundColor: Color(0xff03da9d).withAlpha(30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                ),
                                                label: Text(
                                                  "Approved",
                                                  style: TextStyle(
                                                      color: Color(0xff03da9d)),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "2020-03-29 18:59:22",
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

  void _reverseTransaction(String name, String id, String amount) {
    String displayAmount =
        FlutterMoneyFormatter(amount: double.parse(amount)).output.nonSymbol;
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
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
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
                        name,
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
                        id,
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
