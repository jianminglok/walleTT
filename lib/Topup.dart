import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/tabsContainer.dart';
import 'package:intl/intl.dart';

import 'Login.dart';

import 'Product.dart';

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  var totalAmount = 0;

  @override
  bool get wantKeepAlive => true;

  bool makingPayment = false;
  bool success = false;

  Future<List<Product>> _future;
  Future<List<String>> _sharedStrings;
  Future<String> _paymentResult;
  Future<String> _verifyResult;

  var agentId;
  var agentName;
  var agentSecret;
  var agentBalance;

  TextEditingController _amountController = TextEditingController();

  Future<String> _verify(formData, topupData, balanceData, _amount) async {
    //Do verification when submitting payment
    try {
      Response response =
          await Dio().post("http://10.0.88.178/verify.php", data: formData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'ok') {
        //If verification successful
        try {
          Response response = await Dio()
              .post("http://10.0.88.178/process.php", data: balanceData);
          var jsonData = json.decode(response.toString());

          String remark = jsonData["remark"];

          //If user account is active and not frozen
          if (remark == 'active') {
            //If user has enough balance
            try {
              Response response = await Dio()
                  .post("http://10.0.88.178/process.php", data: topupData);
              var jsonData = json.decode(response.toString());

              String topupStatus = jsonData["status"];

              //Transactions().checkOrderLength();

              if (topupStatus == 'successful') {
                setState(() {
                  _amountController.text = '0';

                  setState(() {
                    _sharedStrings = _refreshBalance();
                  });
                });
              }

              status = topupStatus;
            } catch (e) {
              print(e);
            }
          } else if  (remark == 'frozen') {
            status = 'Account is frozen. Please contact administrator immediately.';
          } else {
            status = jsonData['status'];
          }
        } catch (e) {
          print(e);
        }
      } else {
        status = loginStatus;
      }
      return status;
    } catch (e) {
      print(e);
    }
  }

  var _list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0];

  Widget _buildButton(int index) {
    return Material(
      color: Colors.grey[50],
      child: InkWell(
        child: Center(
          child: index == 11
              ? Icon(Icons.backspace)
              : index == 9
                  ? Semantics()
                  : Text(_list[index].toString(),
                      style: TextStyle(fontSize: 26.0)),
        ),
        onLongPress: () {
          if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            } else {
              _amountController.text = _amountController.text.substring(
                  0,
                  _amountController.text.length -
                      _amountController.text.length);
            }
          }
        },
        onTap: () {
          if (index == 9) {
            return;
          } else if (index == 11) {
            if (_amountController.text.length == 0) {
              return;
            } else {
              _amountController.text = _amountController.text
                  .substring(0, _amountController.text.length - 1);
            }
          } else {
            if (_amountController.text.length == 0) {
              if (index == 10) {
                return;
              } else {
                _amountController.text = _amountController.text == ''
                    ? _list[index].toString()
                    : _amountController.text + _list[index].toString();
              }
            } else {
              _amountController.text = _amountController.text == ''
                  ? _list[index].toString()
                  : _amountController.text + _list[index].toString();
            }
          }
          setState(() {});
        },
      ),
    );
  }

  Future<List<String>> _getUserData() async {
    //Get store id etc
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');

    setState(() {
      _sharedStrings = _getStoreInfo();
    });
  }

  Future<List<String>> _getStoreInfo() async {
    //Get store balance and name
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      List<String> strings = [];
      agentName = prefs.getString('name');
      agentBalance = jsonData['balance'].toString();

      strings.add(agentName);
      strings.add(agentBalance);

      return strings;
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> _refreshBalance() async {
    //Refresh store balance and name after payment complete
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var loginMap = new Map<String, dynamic>();
    loginMap['USER'] = agentId; //Change to storeId later
    loginMap['PASS'] = agentSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/verify.php", data: loginData);
      var jsonData = json.decode(response.toString());

      List<String> strings = [];
      agentName = prefs.getString('name');
      agentBalance = jsonData['balance'].toString();

      strings.add(agentName);
      strings.add(agentBalance);

      return strings;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
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
              onPressed: () async {
                //Logout
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('id');
                prefs.remove('name');
                prefs.remove('status');
                prefs.remove('secret');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext ctx) => Login()));
              },
            ),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 185,
                child: Container(
                  padding: EdgeInsets.only(top: 65.0),
                  child: FutureBuilder<List<String>>(
                      future: _sharedStrings,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center();
                          default:
                            return TabsContainer(
                                name: snapshot.data[0],
                                balance: snapshot.data[1]);
                        }
                      }),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 22.5),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text('How much?',
                            style: TextStyle(
                                fontSize: 40.0, fontWeight: FontWeight.w700)),
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
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text('RM'))),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600),
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
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 2,
                                          mainAxisSpacing: 0.6,
                                          crossAxisSpacing: 0.6),
                                  itemCount: 12,
                                  itemBuilder: (_, index) =>
                                      _buildButton(index)),
                            ]),
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: RaisedButton.icon(
                            icon: Icon(
                              Icons.center_focus_strong,
                              color: Colors.white,
                            ),
                            label: Text("Scan QR Code",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0)),
                            onPressed: () {
                              _scan(_amountController.text, context);
                            },
                          ))
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }

  static Future<String> scan(BuildContext context) async {
    //Scan QR code
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
    //Show dialog after scan complete
    if (_amount.isNotEmpty && int.parse(_amount) > 0) {
      String id = await scan(context);
      String displayAmount =
          FlutterMoneyFormatter(amount: double.parse(_amount)).output.nonSymbol;
      if (id != null) {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(children: <Widget>[
                Container(
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
                        Text('Confirm Topup?',
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
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(DateTime.now()),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
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
                                "Topup Amount (RM)",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              displayAmount,
                              style: TextStyle(
                                  fontSize: 60.0, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            FlatButton(
                              child: Text("Cancel",
                                  style: TextStyle(fontSize: 18.0)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            RaisedButton(
                              child: Text("Confirm",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0)),
                              onPressed: () {
                                var map = new Map<String, dynamic>();
                                map['id'] = id;
                                map['agentId'] =
                                    agentId; //change to storeId later
                                map['time'] = DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.now());
                                map['amount'] = _amount;
                                map['type'] = 'topup';

                                FormData topupData =
                                    new FormData.fromMap(map);

                                var loginMap = new Map<String, dynamic>();
                                loginMap['USER'] =
                                    agentId; //Change to storeId later
                                loginMap['PASS'] =
                                    agentSecret; //Change to storeSecret later
                                loginMap['type'] = 'topup';

                                FormData loginData =
                                    new FormData.fromMap(loginMap);

                                var balanceMap = new Map<String, dynamic>();
                                balanceMap['id'] = id;
                                balanceMap['type'] = 'checkbalance';

                                FormData balanceData =
                                    new FormData.fromMap(balanceMap);

                                if (makingPayment == false) {
                                  _verifyResult = _verify(loginData,
                                      topupData, balanceData, _amount);
                                  Navigator.pop(context);

                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      isDismissible: false,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return Wrap(children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(18),
                                                  topRight: Radius.circular(18),
                                                ),
                                              ),
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      26.0),
                                                  child: Center(
                                                      child:
                                                          FutureBuilder<String>(
                                                              future:
                                                                  _verifyResult,
                                                              builder: (context,
                                                                  snapshot) {
                                                                switch (snapshot
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .none:
                                                                  case ConnectionState
                                                                      .waiting: //Display progress circle while loading
                                                                    return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .stretch,
                                                                        mainAxisSize:
                                                                            MainAxisSize
                                                                                .max,
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          )
                                                                        ]);
                                                                  default: //Display card when loaded
                                                                    return snapshot.data ==
                                                                            'successful'
                                                                        ? Column(
                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                .stretch,
                                                                            mainAxisSize: MainAxisSize
                                                                                .max,
                                                                            children: <
                                                                                Widget>[
                                                                                Center(
                                                                                  child: Icon(
                                                                                    Icons.check,
                                                                                    color: Color(0xff03da9d),
                                                                                    size: 60.0,
                                                                                  ),
                                                                                ),
                                                                                Center(
                                                                                  child: Text(
                                                                                    'Successful',
                                                                                    style: Theme.of(context).textTheme.title,
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 24.0),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                  children: <Widget>[
                                                                                    RaisedButton(
                                                                                      child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                                                      onPressed: () {
                                                                                        setState(() {
                                                                                          makingPayment = false;
                                                                                        });
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              ])
                                                                        : Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.stretch,
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: <Widget>[
                                                                                Center(
                                                                                  child: Icon(
                                                                                    Icons.clear,
                                                                                    color: Theme.of(context).primaryColor,
                                                                                    size: 60.0,
                                                                                  ),
                                                                                ),
                                                                                Center(
                                                                                  child: Text(
                                                                                    snapshot.data.toString(),
                                                                                    style: Theme.of(context).textTheme.title,
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 24.0),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                  children: <Widget>[
                                                                                    RaisedButton(
                                                                                      child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                                                      onPressed: () {
                                                                                        setState(() {
                                                                                          makingPayment = false;
                                                                                        });
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              ]);
                                                                }
                                                              }))))
                                        ]);
                                      });
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Please wait for the previous transaction to finish first"),
                                  ));
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ]);
            });
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please try again"),
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Amount must be larger than 0!"),
      ));
    }
  }
}
