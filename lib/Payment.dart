import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleTT/tabsContainer.dart';
import 'package:intl/intl.dart';

import 'AppState.dart';
import 'Home.dart';
import 'Login.dart';
import 'main.dart';

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  var totalAmount = 0;

  @override
  bool get wantKeepAlive => true;

  bool makingPayment = false;
  bool success = false;

  Future<String> _verifyResult;

  var productsList = [];
  var productsNameList = [];

  var quantities = [];

  var storeId;
  var storeName;
  var storeStatus;
  var storeSecret;
  var storeBalance;

  Future<String> connectivityText;

  String _amountText = '0';

  var _darkTheme = false;

  Future<String> _verify(formData, paymentData, balanceData, _amount) async {
    //Do verification when submitting payment
    try {
      Response response =
          await Dio().post(Home.serverUrl + "process.php", data: formData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'store') {
        //If verification successful
        try {
          Response response = await Dio()
              .post(Home.serverUrl + "process.php", data: balanceData);
          var jsonData = json.decode(response.toString());

          int balance = jsonData["balance"];
          String remark = jsonData["remark"];

          if (jsonData["status"] != 'User does not exist!') {
            //If user from scanned QR code exist
            if (remark == 'active') {
              //If user account is active and not frozen
              if (balance - int.parse(_amount) >= 0) {
                //If user has enough balance
                try {
                  Response response = await Dio()
                      .post(Home.serverUrl + "process.php", data: paymentData);
                  var jsonData = json.decode(response.toString());

                  String paymentStatus = jsonData["status"];

                  //Transactions().checkOrderLength();

                  if (paymentStatus == 'successful') {
                    setState(() {
                      totalAmount = 0;
                      _amountText = '0';

                      final appState =
                          Provider.of<AppState>(context, listen: false);
                      appState.resetProductQuantities();

                      _refreshBalance();
                      _refreshHistory();
                    });
                  }

                  status = paymentStatus;
                } catch (e) {
                  print(e);
                }
              } else {
                status = 'User does not have enough balance!';
              }
            } else if (remark == 'frozen') {
              status =
                  'User account has been frozen. Please contact administrator immediately.';
            } else {
              status = 'User account is not active!';
            }
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

  void _getProducts() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.getProducts();
  }

  Future<void> _refreshProducts() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshProducts();
    setState(() {
      totalAmount = 0;
      _amountText = '0';
    });
  }

  void _getBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.getShopInfo();
  }

  void _refreshBalance() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshShopInfo();
  }

  Future<void> _refreshHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.refreshShopHistory();
  }

  Future<List<String>> _getStoredData() async {
    //Get store id etc
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeSecret = prefs.getString('secret');
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
    _getProducts();
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

  bool _buttonPressed = false;
  bool _loopActive = false;

  void _decreaseQuantity(index) async {
    final appState = Provider.of<AppState>(context, listen: false);
    // make sure that only one loop is active
    if (_loopActive) return;

    _loopActive = true;

    while (_buttonPressed) {
      // do your thing
      setState(() {
        if (appState.getProductQuantities()[index] - 1 >= 0) {
          appState.getProductQuantities()[index] -= 1;
          totalAmount =
              totalAmount - appState.getProductsJson()[index].price.toInt();
          appState.getProductQuantitiesString()[index] =
              appState.getProductQuantities()[index].toString();
          _amountText = totalAmount.toString();
        } else {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Minimum quantity is 0")));
        }
      });
      await Future.delayed(Duration(milliseconds: 100));
    }

    _loopActive = false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2248);
    final appState = Provider.of<AppState>(context);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(460),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  height: ScreenUtil().setHeight(460),
                  padding: EdgeInsets.only(top: ScreenUtil.statusBarHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(child: TabsContainer()),
                    ],
                  )),
              Expanded(
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('Total',
                                style: TextStyle(
                                    fontSize: 27.5,
                                    fontWeight: FontWeight.w500)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('RM ',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    FlutterMoneyFormatter(
                                            amount: double.parse(_amountText))
                                        .output
                                        .nonSymbol,
                                    style: TextStyle(
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.w700)),
                              ],
                            )
                          ],
                        ),
                        appState.isFetchingProducts
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 50.0),
                                child: Center(
                                    child: SpinKitDoubleBounce(
                                  color: Theme.of(context).primaryColor,
                                  size: 50.0,
                                )))
                            : appState.getProductsJson() != null
                                ? Expanded(
                                    child: Container(
                                        child: RefreshIndicator(
                                            key: _refreshIndicatorKey,
                                            onRefresh: _refreshProducts,
                                            child: ListView.builder(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                shrinkWrap: true,
                                                itemCount: appState
                                                    .getProductsJson()
                                                    .length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                            int index) =>
                                                        Container(
                                                            width:
                                                                double.infinity,
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18),
                                                              ),
                                                              child: InkWell(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          5.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            ListTile(
                                                                                title: Text(
                                                                                  appState.getProductsJson()[index].name,
                                                                                  style: Theme.of(context).textTheme.title,
                                                                                ),
                                                                                subtitle: Container(
                                                                                  padding: EdgeInsets.only(top: 10.0),
                                                                                  child: Text(
                                                                                    'RM ' + FlutterMoneyFormatter(amount: appState.getProductsJson()[index].price).output.nonSymbol,
                                                                                    style: Theme.of(context).textTheme.subhead,
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          flex:
                                                                              3,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                  width: 50.0,
                                                                                  height: 80.0,
                                                                                  child: FlatButton(
                                                                                    child: const Text('-', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300)),
                                                                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                    onPressed: () {
                                                                                      if (appState.getProductQuantities()[index] - 1 >= 0) {
                                                                                        appState.getProductQuantities()[index] -= 1;
                                                                                        appState.getProductQuantitiesString()[index] = appState.getProductQuantities()[index].toString();
                                                                                        setState(() {
                                                                                          totalAmount = totalAmount - appState.getProductsJson()[index].price.toInt();
                                                                                          _amountText = totalAmount.toString();
                                                                                        });
                                                                                      } else {
                                                                                        Scaffold.of(context).removeCurrentSnackBar();
                                                                                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Minimum quantity is 0")));
                                                                                      }
                                                                                    },
                                                                                  )),
                                                                              Text(
                                                                                appState.getProductQuantitiesString()[index],
                                                                                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                                                                              ),
                                                                              Container(
                                                                                  width: 50.0,
                                                                                  height: 80.0,
                                                                                  child: FlatButton(
                                                                                    child: const Text('+', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300)),
                                                                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                    onPressed: () {
                                                                                      appState.getProductQuantities()[index] += 1;
                                                                                      appState.getProductQuantitiesString()[index] = appState.getProductQuantities()[index].toString();
                                                                                      setState(() {
                                                                                        totalAmount = totalAmount + appState.getProductsJson()[index].price.toInt();
                                                                                        _amountText = totalAmount.toString();
                                                                                      });
                                                                                    },
                                                                                  )),
                                                                            ],
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ))))))
                                : Center(
                                    child: Container(
                                    margin:
                                        EdgeInsets.symmetric(vertical: 50.0),
                                    child: Text(
                                        "No response from server. Please try again later."),
                                  )),
                        SizedBox(
                            width: double.infinity,
                            height: ScreenUtil().setHeight(130),
                            child: RaisedButton.icon(
                              icon: Icon(
                                Icons.center_focus_strong,
                                color: Colors.white,
                              ),
                              label: Text("Scan QR Code",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(54,
                                          allowFontScalingSelf: true))),
                              onPressed: () {
                                _scan(_amountText,
                                    appState.getProductQuantities(), context);
                              },
                            )),
                      ],
                    )),
              )
            ],
          ),
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
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Camera permission not obtained!"),
          ));
        }
      }
    }
    return null;
  }

  void _scan(String _amount, quantities, BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);

    //Show dialog after scan complete
    final idList = [];
    final quantitiesList = [];
    final nameList = [];

    var products = [];
    var names = [];

    for (var i in appState.getProductsJson()) {
      products.add(i.productId);
      names.add(i.name);
    }

    if (_amount.isNotEmpty && int.parse(_amount) > 0) {
      for (var i = 0; i < quantities.length; i++) {
        if (quantities[i] != 0) {
          idList.add('"' + products[i].toString() + '"');
          quantitiesList.add(quantities[i]);
          nameList.add(names[i]);
        }
      }

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
                        Text('Confirm Payment?',
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
                                "User ID",
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
                                "Product",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                        color: _darkTheme
                                            ? Colors.white54
                                            : Colors.black54),
                              ),
                              Text(
                                "Quantity",
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
                            Expanded(
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: _darkTheme
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                    shrinkWrap: true,
                                    itemCount: nameList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              nameList[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              quantitiesList[index].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      );
                                    }))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Amount (RM)",
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
                                map['userId'] = id;
                                map['storeId'] =
                                    storeId; //change to storeId later
                                map['time'] = DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.now());
                                map['amount'] = _amount;
                                map['products'] = idList.toString();
                                map['numbers'] = quantitiesList.toString();
                                map['type'] = 'payment';

                                FormData paymentData =
                                    new FormData.fromMap(map);

                                var loginMap = new Map<String, dynamic>();
                                loginMap['STORE'] =
                                    storeId; //Change to storeId later
                                loginMap['PASS'] =
                                    storeSecret; //Change to storeSecret later
                                loginMap['type'] = 'login';

                                FormData loginData =
                                    new FormData.fromMap(loginMap);

                                var balanceMap = new Map<String, dynamic>();
                                balanceMap['id'] = id;
                                balanceMap['type'] = 'checkbalance';

                                FormData balanceData =
                                    new FormData.fromMap(balanceMap);

                                if (makingPayment == false) {
                                  _verifyResult = _verify(loginData,
                                      paymentData, balanceData, _amount);
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
                                                                              child: Center(
                                                                                  child: SpinKitDoubleBounce(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            size:
                                                                                50.0,
                                                                          )))
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
                                  Scaffold.of(context).removeCurrentSnackBar();
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
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please scan a valid QR code"),
        ));
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Please try again"),
        ));
      }
    } else {
      Scaffold.of(context).removeCurrentSnackBar();
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
