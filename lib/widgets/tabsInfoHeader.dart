import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/providers/filterState.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:walleTT/providers/settingsState.dart';

class TabsInfoHeader extends StatelessWidget {

  final String name;
  final String balance;

  TabsInfoHeader({Key key, @required this.name, @required this.balance}) : super(key: key);

  String getTotalAmountFormatted(
      List<DocumentSnapshot> tabs, String currencySymbol) {
    double total = 0;
    for (DocumentSnapshot tab in tabs) {
      if (tab["closed"] != true)
        tab["userOwesFriend"] == true
            ? total -= tab["amount"]
            : total += tab["amount"];
    }
    return "$currencySymbol ${FlutterMoneyFormatter(amount: total).output.nonSymbol}";
  }

  String getHeaderText(List<DocumentSnapshot> tabs) {
    String text = "${tabs.length} OPEN TAB";
    if (tabs.length != 1) text += "S";
    return text;
  }

  Widget displayFilterChip(String name, Function onDeleted) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      child: Chip(
        backgroundColor: Colors.white70,
        label: Text("$name's tabs"),
        onDeleted: onDeleted,
        deleteIcon: Icon(Icons.clear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "$name's Current Balance",
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Rubik'),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
              'RM ' + FlutterMoneyFormatter(amount: double.parse(balance)).output.nonSymbol,
              style: Theme.of(context).textTheme.display2),
          SizedBox(
            height: 10,
          ),

        ],
      ),
    );
  }
}
