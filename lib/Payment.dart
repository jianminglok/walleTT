import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:walleTT/tabsContainer.dart';
import 'package:intl/intl.dart';

import 'Order.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  TextEditingController _amountController = TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  final quantities = [];
  final quantitiesString = [];

  @override
  void initState() {
    super.initState();
  }

  var _list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0];

  Widget _buildButton(int index) {
    return Material(
      color: Colors.grey[50],
      child: InkWell(
        child: Center(
          child: index == 11 ? Icon(Icons.backspace) : index == 9 ? Semantics() : Text(_list[index].toString(), style: TextStyle(fontSize: 26.0)),
        ),
        onLongPress: () {
          if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            }
            else {
              _amountController.text = _amountController.text.substring(0, _amountController.text.length - _amountController.text.length);
            }
          }
        },
        onTap: () {
          if (index == 9) {
            return;
          }
          else if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            }
            else {
              _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
            }
          }
          else {
            if (_amountController.text.length == 0) {
              if (index == 10) {

                return;
              } else {
                _amountController.text = _amountController.text == '' ? _list[index].toString() : _amountController.text + _list[index].toString();
              }
            }
            else {
              _amountController.text = _amountController.text == '' ? _list[index].toString() : _amountController.text + _list[index].toString();
            }
          }
          setState(() {
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: <Widget>[
          Container(
            height: 185,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.6],
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.50, 18),
                bottomRight: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.50, 18),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.exit_to_app),
              onPressed: () {

              },
            ),
          ),
          Positioned(
            top: 30,
            right: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.settings),
              onPressed: () {

              },
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 65.0),
                child: TabsContainer(),
              ),
              Container(
                  margin: EdgeInsets.only(top: 40.0),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text('How much?', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700)),
                      ),
                      Container(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text('5'),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _amountController.text = '5';
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text('10'),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _amountController.text = '10';
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text('20'),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _amountController.text = '20';
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text('50'),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _amountController.text = '50';
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text('100'),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _amountController.text = '100';
                                  },
                                ),
                              ),
                            ],
                          ),
                      ),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(contentPadding: EdgeInsets.all(12), prefixIcon: Padding(padding: EdgeInsets.all(15), child: Text('RM'))),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2,
                                mainAxisSpacing: 0.6,
                                crossAxisSpacing: 0.6
                              ),
                              itemCount: 12,
                              itemBuilder: (_, index) => _buildButton(index)
                            ),
                          ]
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: RaisedButton.icon(
                          icon: Icon(Icons.center_focus_strong, color: Colors.white,),
                          label: Text("Scan QR Code", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                          onPressed: () {
                            _scan(_amountController.text, context);
                          },
                        )
                      )
                    ],
                  )
              )
            ],
          ),
        ],
      ),
      //floatingActionButton: FloatingActionButton.extended(
      //    onPressed: () {
      //      Navigator.push( //Open QR Scanner
      //        context,
      //        MaterialPageRoute(builder: (context) => BarcodeScanner(),
      //        settings: RouteSettings(
      //        arguments: quantities,
      //        ),
      //        ),
      //      );
      //    },
      //     label: Text('Scan QR'),
      //    icon: Icon(Icons.add)),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  static Future<String> scan(BuildContext context) async {
    try {
      return await BarcodeScanner.scan();
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == BarcodeScanner.CameraAccessDenied) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Camera permission not obtained!"),
          ));
        }
      }
    }
    return null;
  }

  void _scan(String _amount, BuildContext context) async {
    if(_amount.isNotEmpty) {
      String id = await scan(context);
      String displayAmount =
          FlutterMoneyFormatter(amount: double.parse(_amount)).output.nonSymbol;
      if (id != null) {
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
                          'Confirm Payment?',
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
                            'ABCDE',
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
                            Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
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
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please try again"),
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Amount cannot be empty!"),
      ));
    }
  }
}