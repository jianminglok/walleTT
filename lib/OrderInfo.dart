import 'dart:convert';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';
import 'package:walleTT/Transactions.dart';

import 'Order.dart';
import 'barcode_scanner.dart';
import 'package:http/http.dart' as http;

class OrderInfo extends StatefulWidget {

  OrderInfo({Key key}) : super(key: key);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final OrderInfoArguments args = ModalRoute.of(context).settings.arguments;

    String displayAmount =
        FlutterMoneyFormatter(amount: args.amount).output.nonSymbol;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Order Info"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
        ),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                      'Order ' + args.orderId.toString(),
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
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(args.time)),
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
                        args.userName + ' (' + args.userId + ')' ,
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
                          "Products",
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'WIP',
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
                        style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  //Padding(
                  //  padding: const EdgeInsets.only(top: 24.0),
                  //    child:
                  //    SizedBox(
                  //        width: double.infinity,
                  //        height: 50.0,
                  //        child: RaisedButton(
                  //          child: Text("Reverse Transaction", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  //          onPressed: () {
                  //            if(args.status == 'Approved') {
                  //              _reverseTransaction(
                  //                  args.time,
                  //                  args.userName,
                  //                  args.userId,
                  //                  args.orderId,
                  //                  args.amount);
                  //            } else if (args.status == 'Reversed') {
                  //              Scaffold.of(context).showSnackBar(SnackBar(
                  //                content: Text("Transaction already reversed"),
                  //              ));
                  //            }
                  //          },
                  //        )
                  //    )
                  //)
                ],
              ),
            ),
            )
          ],
        )
    );
  }

  void _reverseTransaction(String time, String userName, String userId, int orderId, double amount) {
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
                      'Order ' + orderId.toString(),
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
                        userName + ' (' + userId + ')' ,
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
                          "Products",
                          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'WIP',
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
                        style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w800),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}