import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:walleTT/controllers/tabsController.dart';
import 'package:walleTT/providers/filterState.dart';
import 'package:walleTT/widgets/tabsGrid.dart';
import 'package:walleTT/widgets/tabsInfoHeader.dart';

class TabsContainer extends StatefulWidget {

  final String name;
  final String balance;

  TabsContainer({Key key, @required this.name, @required this.balance}) : super(key: key);

  @override
  _TabsContainerState createState() => _TabsContainerState(name, balance);
}

class _TabsContainerState extends State<TabsContainer> {
  int currentPageIndex = 0;

  String name;
  String balance;

  _TabsContainerState(String name, String balance) {
    this.name = name;
    this.balance = balance;
  }

  Widget circleBar(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      height: 12,
      width: isActive ? 24 : 12,
      decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  @override
  Widget build(BuildContext context) {
          return ChangeNotifierProvider<FilterState>(
            create: (context) => FilterState(),
            child: Column(
              children: <Widget>[
                Center(
                  child: TabsInfoHeader(name: name, balance: balance,),
                ),
              ],
            ),
          );

  }
}
