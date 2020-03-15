import 'dart:convert';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:placeholderflutter/barcode_scanner.dart';

import 'API.dart';
import 'User.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  final quantities = [];
  final quantitiesString = [];

  Future<List<User>> _future;

  Future<List<User>> _getUsers() async {
    var data = await http.get("https://jsonplaceholder.typicode.com/users");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var i in jsonData) {
      User user = User(i["id"], i["name"], i["email"]);

      users.add(user);

      quantities.add(0);
      quantitiesString.add("0");
    }

    print(users.length);

    return users;
  }

  Future<List<User>> _refresh() async {
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
        title: Text("Payment"),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 47.5),
                child: Text(
                  'RM 10',
                  style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
                ),
              )
          ),
          FutureBuilder<List<User>>(
            future: _future,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    child: Center(
                      child:
                        CircularProgressIndicator(),

                    )
                  );
                default:
                  return Expanded(
                    child:
                    RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refresh,
                        child:
                    ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) =>
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 2.5, 10, 2.5),
                            child: Card( //                           <-- Card widget
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: (
                                        ListTile(
                                          title: Text(
                                              snapshot.data[index].name),
                                          subtitle: Text('$index'),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    child: (
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              SizedBox(
                                                width: 30.0,
                                                child: (
                                                    FlatButton(
                                                      child: const Text(
                                                          '-', style: TextStyle(
                                                          fontSize: 50.0,
                                                          fontWeight: FontWeight
                                                              .w200)),
                                                      padding: EdgeInsets
                                                          .fromLTRB(0, 0, 0, 0),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (quantities[index] -
                                                              1 >= 0) {
                                                            quantities[index] -=
                                                            1;
                                                            quantitiesString[index] =
                                                                quantities[index]
                                                                    .toString();
                                                          } else {
                                                            Scaffold.of(context)
                                                                .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        "Minimum quantity is 0")));
                                                          }
                                                        });
                                                      },
                                                    )
                                                ),
                                              ),
                                              Text(
                                                quantitiesString[index],
                                                style: TextStyle(
                                                    fontSize: 25.0,
                                                    fontWeight: FontWeight
                                                        .w400),
                                              ),
                                              SizedBox(
                                                  width: 30.0,
                                                  child: (
                                                      FlatButton(
                                                        child: const Text('+',
                                                            style: TextStyle(
                                                                fontSize: 30.0,
                                                                fontWeight: FontWeight
                                                                    .w300)),
                                                        padding: EdgeInsets
                                                            .fromLTRB(
                                                            0, 0, 0, 0),
                                                        onPressed: () {
                                                          setState(() {
                                                            quantities[index] +=
                                                            1;
                                                            quantitiesString[index] =
                                                                quantities[index]
                                                                    .toString();
                                                          });
                                                        },
                                                      )
                                                  )
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ],
                              ),

                            ))

                    )
                        // body of above
                    )
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BarcodeScanner(),
              settings: RouteSettings(
              arguments: quantities,
              ),
              ),
            );
          },
          label: Text('Scan QR'),
          icon: Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}