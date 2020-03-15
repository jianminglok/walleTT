import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placeholderflutter/barcode_scanner.dart';

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

  Future<List<User>> _getUsers() async { //Get list of users from server
    var data = await http.get("https://jsonplaceholder.typicode.com/users");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var i in jsonData) {
      User user = User(i["id"], i["name"], i["email"]);

      users.add(user);

      quantities.add(0); //Populate array with int 0
      quantitiesString.add("0"); //Populate array with string "0" so it can be displayed
    }

    print(users.length);

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
        title: Text("Payment"),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 47.5),
                child: Text( //Total amount widget
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
                case ConnectionState.waiting: //Display progress circle while loading
                  return Container(
                    child: Center(
                      child:
                        CircularProgressIndicator(),

                    )
                  );
                default: //Display card when loaded
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
                                              snapshot.data[index].name), //Show User Name
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
                                              SizedBox( //Add or subtract product quantity
                                                width: 30.0,
                                                child: (
                                                    FlatButton( //Button to decrease quantity
                                                      child: const Text(
                                                          '-', style: TextStyle(
                                                          fontSize: 50.0,
                                                          fontWeight: FontWeight
                                                              .w200)),
                                                      padding: EdgeInsets
                                                          .fromLTRB(0, 0, 0, 0),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (quantities[index] - //Minimum quantity must be 0
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
                                                      FlatButton( //Button to increase quantity
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
            Navigator.push( //Open QR Scanner
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