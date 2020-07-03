import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/pin-pad/numpad.dart';
import 'package:walleTT/tabsContainer.dart';
import 'package:intl/intl.dart';

import 'AppState.dart';
import 'Balance.dart';
import 'Freeze.dart';
import 'Home.dart';
import 'Login.dart';

import 'Product.dart';
import 'main.dart';

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

  var _darkTheme = false;

  TextEditingController _amountController = TextEditingController();

  Future<String> _verify(formData, topupData, balanceData, _amount) async {
    //Do verification when submitting payment
    try {
      Response response =
          await Dio().post(Home.serverUrl + "verify.php", data: formData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'agent') {
        //If verification successful
        try {
          Response response = await Dio()
              .post(Home.serverUrl + "process.php", data: balanceData);
          var jsonData = json.decode(response.toString());

          String remark = jsonData["remark"];

          //If user account is active and not frozen
          if (remark == 'active') {
            //If user has enough balance
            try {
              Response response = await Dio()
                  .post(Home.serverUrl + "process.php", data: topupData);
              var jsonData = json.decode(response.toString());

              String topupStatus = jsonData["status"];

              //Transactions().checkOrderLength();

              if (topupStatus == 'successful') {
                setState(() {
                  _amountController.text = '';
                });

                _refreshBalance();
                _refreshHistory();
              }

              status = topupStatus;
            } catch (e) {
              print(e);
            }
          } else if (remark == 'frozen') {
            status =
                'Account is frozen. Please contact administrator immediately.';
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
                      style: TextStyle(fontSize: 65.ssp)),
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

  void _getBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.getUserData();
  }

  void _refreshBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserData();
  }

  Future<void> _getHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.getUserHistory();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshUserHistory();
  }

  Future<List<String>> _getStoredData() async {
    //Get store id etc
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    agentId = prefs.getString('id');
    agentSecret = prefs.getString('secret');
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool verifyQRValidity(String qr) {
    var code = qr.splitByLength(1)[1].splitByLength(9)[0];
    var sum = 0;
    for (int i = 0; i < code.length; i++) {
      if (isNumeric(code[code.length - 2]) &&
          !isNumeric(code[code.length - 1])) {
        if (i < code.length - 2) {
          sum += int.parse(code[i]);
        } else {
          if ((sum % 10) == int.parse(code[code.length - 2])) {
            return true;
          } else {
            return false;
          }
        }
      } else {
        return false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getStoredData();
    _getBalance();
    _getHistory();
    _checkConnectivity().then((intenet) {
      if (intenet != null && intenet) {
        // Internet Present Case
      } else {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => _showConnectivityDialog());
      }
    });
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('wallett.gq');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2248);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: 460.h,
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
          top: 30.75,
          left: 5,
          child: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: _darkTheme
                    ? Text("Disable Dark Theme")
                    : Text("Enable Dark Theme"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Logout"),
              ),
            ],
            offset: Offset(0, 7.5),
            onSelected: (value) {
              if (value == 1) {
                setState(() {
                  _darkTheme = !_darkTheme;
                });
                onThemeChanged(_darkTheme, themeNotifier);
              } else if (value == 2) {
                _showLogoutDialog();
              }
            },
            icon: Icon(Icons.more_vert, color: Colors.white),
          ),
        ),
        Positioned(
          top: 30,
          right: 5,
          child: IconButton(
            color: Colors.white,
            icon: Icon(Icons.warning, color: Colors.white),
            onPressed: () {
              Navigator.push(
                //Open QR Scanner
                context,
                MaterialPageRoute(
                  builder: (context) => Freeze(),
                ),
              );
            },
          ),
        ),
        Column(
          children: <Widget>[
            Container(
                height: 460.h,
                padding: EdgeInsets.only(top: ScreenUtil.statusBarHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(child: TabsContainer()),
                  ],
                )),
            Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('How much?',
                            style: TextStyle(
                                fontSize: 100.ssp,
                                fontWeight: FontWeight.w700)),
                        SizedBox(
                          height: 1100.h,
                          child: NumPad(
                            /* numpad must always have a controller attached to it. */
                            controller: _amountController,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 35.h),
                        ),
                        SizedBox(
                            width: double.infinity,
                            height: 130.h,
                            child: RaisedButton.icon(
                              icon: Icon(
                                Icons.center_focus_strong,
                                color: Colors.white,
                              ),
                              label: Text("Scan QR Code",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 54.ssp)),
                              onPressed: () {
                                _scan(_amountController.text, context);
                              },
                            ))
                      ],
                    )))
          ],
        )
      ],
    ));
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
      if (id != null &&
          id.isNotEmpty &&
          id.contains('U') &&
          id.length == 69 &&
          verifyQRValidity(id)) {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: _darkTheme ? Colors.grey.shade800 : Colors.white,
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
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
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
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              id.splitByLength(1)[1].splitByLength(7)[0],
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
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
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
                                  fontSize: 150.ssp,
                                  fontWeight: FontWeight.w800),
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
                                map['userId'] = id;
                                map['agentId'] =
                                    agentId; //change to storeId later
                                map['time'] = DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.now());
                                map['amount'] = _amount;
                                map['type'] = 'topup';

                                FormData topupData = new FormData.fromMap(map);

                                var loginMap = new Map<String, dynamic>();
                                loginMap['USER'] =
                                    agentId; //Change to storeId later
                                loginMap['PASS'] =
                                    agentSecret; //Change to storeSecret later
                                loginMap['type'] = 'login';

                                FormData loginData =
                                    new FormData.fromMap(loginMap);

                                var balanceMap = new Map<String, dynamic>();
                                balanceMap['id'] = id;
                                balanceMap['type'] = 'checkbalance';

                                FormData balanceData =
                                    new FormData.fromMap(balanceMap);

                                if (makingPayment == false) {
                                  _verifyResult = _verify(loginData, topupData,
                                      balanceData, _amount);
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
                                                color: _darkTheme
                                                    ? Colors.grey.shade800
                                                    : Colors.white,
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
                                                                              child: SpinKitDoubleBounce(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            size:
                                                                                50.0,
                                                                          ))
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
      } else if ((id != null && id.isNotEmpty && !id.contains('U')) ||
          (id != null && id.isNotEmpty && id.length != 69) ||
          (id != null && id.isNotEmpty && !verifyQRValidity(id))) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please scan a valid QR code"),
        ));
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

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text("Confirm logout?"),
            content: Text(
                "You can only perform transactions after you have logged in"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text("Logout"),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('id');
                  prefs.remove('name');
                  prefs.remove('status');
                  prefs.remove('secret');
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (BuildContext ctx) => Login()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        } else
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              "Confirm logout?",
              style: TextStyle(fontFamily: 'Rubik'),
            ),
            content: Text(
              "You can only perform transactions after you have logged in",
              style: TextStyle(fontFamily: 'Rubik'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontFamily: 'Rubik'),
                ),
                textColor: Colors.black87,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Logout",
                  style: TextStyle(fontFamily: 'Rubik'),
                ),
                textColor: Colors.red,
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('id');
                  prefs.remove('name');
                  prefs.remove('status');
                  prefs.remove('secret');
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (BuildContext ctx) => Login()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
      },
    );
  }

  void _showConnectivityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text("Error"),
            content:
                Text("Please make sure you have an active internet connection"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              "Error",
              style: TextStyle(fontFamily: 'Rubik'),
            ),
            content: Text(
              "Please make sure you have an active internet connection",
              style: TextStyle(fontFamily: 'Rubik'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(fontFamily: 'Rubik'),
                ),
                textColor: Colors.black87,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
      },
    );
  }
}

extension on String {
  List<String> splitByLength(int length) =>
      [substring(0, length), substring(length)];
}