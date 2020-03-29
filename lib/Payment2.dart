import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:walleTT/barcode_scanner.dart';
import 'package:walleTT/widgets/rise_number_text.dart';

import 'User.dart';
import 'package:http/http.dart' as http;

import 'colors.dart';
import 'dimens.dart';
import 'gaps.dart';

class Payment2 extends StatefulWidget {
  Payment2({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment2> {

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
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: <Widget>[
                    const _AccountMoney(
                      title: '当前余额(元)',
                      money: '30.12',
                      alignment: MainAxisAlignment.end,
                      moneyTextStyle: const TextStyle(color: Colors.white, fontSize: 32.0, fontWeight: FontWeight.bold, fontFamily: 'RobotoThin'),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          const _AccountMoney(title: '累计结算金额', money: '20000'),
                          const _AccountMoney(title: '累计发放佣金', money: '0.02'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

class _AccountMoney extends StatelessWidget {

  const _AccountMoney({
    Key key,
    @required this.title,
    @required this.money,
    this.alignment,
    this.moneyTextStyle
  }): super(key: key);

  final String title;
  final String money;
  final MainAxisAlignment alignment;
  final TextStyle moneyTextStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Column(
          mainAxisAlignment: alignment ?? MainAxisAlignment.center,
          children: <Widget>[
            /// 横向撑开Column，扩大语义区域
            const SizedBox(width: double.infinity),
            Text(title, style: TextStyle(color: Colours.text_disabled, fontSize: Dimens.font_sp12)),
            Gaps.vGap8,
            RiseNumberText(
                NumUtil.getDoubleByValueStr(money),
                style: moneyTextStyle ?? TextStyle(
                    color: Colours.text_disabled,
                    fontSize: Dimens.font_sp14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoThin'
                )
            ),
          ],
        ),
      ),
    );
  }
}