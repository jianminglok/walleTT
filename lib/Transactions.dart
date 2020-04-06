import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Transaction.dart';
import 'TransactionInfo.dart';

int orderLength;
Future<List<Transaction>> _future;

class Transactions extends StatefulWidget {

  Transactions({Key key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  var agentId;
  var agentName;
  var agentSecret;

  @override
  bool get wantKeepAlive => true;

  Future<List<Transaction>> _verify() async { //Do verification before getting list of transactions

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'topuphistory';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response = await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if(loginStatus == 'ok') { //If verification is successful
        var map = new Map<String, dynamic>();
        map['id'] = agentId; //change to storeId later
        map['type'] = 'topuphistory';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio().post("http://10.0.88.178/process.php", data: formData);

          var jsonData = json.decode(response.toString());

          List<Transaction> users = [];

          for (var i in jsonData) {
            Transaction user = Transaction(
                int.parse(i["id"]), double.parse(i["amount"]), i["time"],
                i["user"]["id"], i["user"]["name"], i["remark"], i["cleared"]);

            users.add(user);
          }
          return users;
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

  Future<List<Transaction>> refreshOrder() async { //Refresh list of transactions from server
    setState(() {
      _future = _verify();
    });
  }

  Future<void> _getUserData() async { //Get store id, name etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentId = prefs.getString('id');
    agentName = prefs.getString('name');
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
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title: new Text("Transactions"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FutureBuilder<List<Transaction>>(
              future: _future,
              builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting: //Display progress circle while loading
                  return Container(
                    child: Center(
                        child: SpinKitDoubleBounce(
                          color: Theme.of(context).primaryColor,
                          size: 50.0,
                        )
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
                                                    snapshot.data[index].topupId,
                                                    snapshot.data[index].amount,
                                                    snapshot.data[index].remark,
                                                    snapshot.data[index].cleared),
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
                                                    'Transaction ID: ' + snapshot.data[index].topupId.toString(),
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
                                                  Text(
                                                    StringUtils.capitalize(snapshot.data[index].remark),
                                                    style: Theme.of(context).textTheme.subtitle,
                                                  ),
                                                ],
                                              ),
                                              Chip(
                                                backgroundColor: snapshot.data[index].cleared == 'cleared' ? Color(0xff03da9d).withAlpha(30) : Theme.of(context).primaryColor.withAlpha(30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                ),
                                                label: Text(
                                                  StringUtils.capitalize(snapshot.data[index].cleared),
                                                  style: TextStyle(color:
                                                      snapshot.data[index].cleared == 'cleared' ? Color(0xff03da9d) : Theme.of(context).primaryColor),
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
}

class OrderInfoArguments {
  final String time;
  final String userName;
  final String userId;
  final int topupId;
  final double amount;
  final String remark;
  final String cleared;

  OrderInfoArguments(this.time, this.userName, this.userId, this.topupId, this.amount, this.remark, this.cleared);
}