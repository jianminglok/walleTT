import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppState.dart';
import 'Transaction.dart';
import 'TransactionInfo.dart';
import 'main.dart';

int orderLength;
Future<List<Transaction>> _future;

class Transactions extends StatefulWidget {
  Transactions({Key key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  var agentId;
  var agentName;
  var agentSecret;

  var _darkTheme = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _getStoredData() async {
    //Get store id, name etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');
  }

  void _getHistory() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.getUserHistory();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserHistory();
  }

  @override
  void initState() {
    super.initState();
    _getStoredData();
    _getHistory();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Transactions"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            appState.isFetchingUser
                ? Container(
                    child: Center(
                        child: SpinKitDoubleBounce(
                    color: Theme.of(context).primaryColor,
                    size: 50.0,
                  )))
                : appState.getUserHistoryJson() != null
                    ? appState.getUserHistoryJson().length > 0
                        ? Expanded(
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                child: RefreshIndicator(
                                    key: _refreshIndicatorKey,
                                    onRefresh: _refreshHistory,
                                    child: ListView.builder(
                                        itemCount: appState
                                            .getUserHistoryJson()
                                            .length,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                Container(
                                                    child: Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 1.25, 20, 1.25),
                                                  child: SizedBox(
                                                      height: 165,
                                                      width: double.infinity,
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                        ),
                                                        child: InkWell(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                          onLongPress: () {},
                                                          onTap: () {
                                                            Navigator.push(
                                                              //Open QR Scanner
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OrderInfo(),
                                                                settings:
                                                                    RouteSettings(
                                                                  arguments: OrderInfoArguments(
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .time,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .userName,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .userId,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .topupId,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .amount,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .remark,
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .cleared),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      //appState.getUserHistoryJson()[index].userName + ' (' + appState.getUserHistoryJson()[index].userId + ')',
                                                                      appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .userName, //Not enough space on small phones
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .subhead,
                                                                    ),
                                                                    Text(
                                                                      'ID: ' +
                                                                          appState
                                                                              .getUserHistoryJson()[index]
                                                                              .topupId
                                                                              .toString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .subhead,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 8.0),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'RM ' +
                                                                          appState
                                                                              .getUserHistoryJson()[index]
                                                                              .amount
                                                                              .toStringAsFixed(2),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headline
                                                                          .copyWith(
                                                                              fontWeight: FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      StringUtils.capitalize(appState
                                                                          .getUserHistoryJson()[
                                                                              index]
                                                                          .remark),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .subtitle,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Chip(
                                                                  backgroundColor: appState
                                                                              .getUserHistoryJson()[
                                                                                  index]
                                                                              .cleared ==
                                                                          'cleared'
                                                                      ? _darkTheme
                                                                      ? Color(0xff03da9d).withAlpha(
                                                                      75)
                                                                      : Color(0xff03da9d).withAlpha(
                                                                      30)
                                                                      : _darkTheme
                                                                      ? Theme.of(context).primaryColor.withAlpha(
                                                                      75)
                                                                      : Theme.of(context)
                                                                      .primaryColor
                                                                      .withAlpha(30),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius
                                                                          .circular(
                                                                              8),
                                                                    ),
                                                                  ),
                                                                  label: Text(
                                                                    StringUtils.capitalize(appState
                                                                        .getUserHistoryJson()[
                                                                            index]
                                                                        .cleared),
                                                                    style: TextStyle(
                                                                        color: appState.getUserHistoryJson()[index].cleared ==
                                                                                'cleared'
                                                                            ? Color(0xff03da9d)
                                                                            : Theme.of(context).primaryColor),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        appState
                                                                            .getUserHistoryJson()[index]
                                                                            .time,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .body1,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                ))))))
                        : Center(
                            child: Container(
                            child: Text("No transactions yet."),
                          ))
                    : Center(
                        child: Container(
                        child: Text(
                            "No response from server. Please try again later."),
                      ))
          ],
        ));
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

  OrderInfoArguments(this.time, this.userName, this.userId, this.topupId,
      this.amount, this.remark, this.cleared);
}
