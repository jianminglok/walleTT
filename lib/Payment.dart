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

  var quantities = [];
  var quantitiesString = [];
  var productsList = [];
  var productsNameList = [];

  var storeId;
  var storeName;
  var storeStatus;
  var storeSecret;
  var storeBalance;

  TextEditingController _amountController = TextEditingController();

  Future<String> _verify(formData, paymentData, balanceData, _amount) async { //Do verification when submitting payment
    try {
      Response response =
          await Dio().post("http://10.0.88.178/process.php", data: formData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'store') { //If verification successful
        try {
          Response response = await Dio()
              .post("http://10.0.88.178/process.php", data: balanceData);
          var jsonData = json.decode(response.toString());

          int balance = jsonData["balance"];
          String remark = jsonData["remark"];

          if(jsonData["status"] != 'User does not exist!') { //If user from scanned QR code exist
            if (remark == 'active') { //If user account is active and not frozen
              if (balance - int.parse(_amount) >= 0) { //If user has enough balance
                try {
                  Response response = await Dio()
                      .post("http://10.0.88.178/process.php", data: paymentData);
                  var jsonData = json.decode(response.toString());

                  String paymentStatus = jsonData["status"];

                  //Transactions().checkOrderLength();

                  if (paymentStatus == 'successful') {
                    setState(() {
                      totalAmount = 0;
                      for (var i = 0; i < quantities.length; i++) {
                        quantitiesString[i] = '0';
                        quantities[i] = 0;
                        _amountController.text = '0';
                      }

                      setState(() {
                        _sharedStrings = _refreshStoreInfo();
                      });
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
              status = 'User account has been frozen. Please contact administrator immediately.';
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

  Future<List<Product>> _getProducts() async { //Get list of products
    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      String loginStatus = jsonData["status"];
      String status;

      if (loginStatus == 'store') {
        var map = new Map<String, dynamic>();
        map['id'] = storeId; //change to storeId later
        map['type'] = 'products';

        FormData formData = new FormData.fromMap(map);

        try {
          Response response = await Dio()
              .post("http://10.0.88.178/process.php", data: formData);

          var jsonData = json.decode(response.toString());

          List<Product> products = [];

          for (var i in jsonData) {
            Product product =
                Product(i["id"], i["name"], double.parse(i["price"]));

            products.add(product);

            quantities.add(0);
            quantitiesString.add("0");
            productsNameList.add(i["name"]);
            productsList.add(i["id"]);
          }

          return products;
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

  Future<List<Product>> _refresh() async { //Refresh product list
    //Refresh list of users from server
    setState(() {
      totalAmount = 0;
      for (var i = 0; i < quantities.length; i++) {
        quantitiesString[i] = '0';
        quantities[i] = 0;
        _amountController.text = '0';
      }
      _future = _getProducts();
    });
  }

  Future<List<String>> _getUserData() async { //Get store id etc
    SharedPreferences prefs = await SharedPreferences.getInstance();

    storeId = prefs.getString('id');
    storeStatus = prefs.getString('status');
    storeSecret = prefs.getString('secret');

    setState(() {
      _sharedStrings = _getStoreInfo();
      _future = _getProducts();
    });
  }

  Future<List<String>> _getStoreInfo() async { //Get store balance and name
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      List<String> strings = [];
      storeName = prefs.getString('name');
      storeBalance = jsonData['balance'].toString();

      strings.add(storeName);
      strings.add(storeBalance);

      prefs.setString('balance', storeBalance);

      return strings;
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> _refreshStoreInfo() async { //Refresh store balance and name after payment complete
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var loginMap = new Map<String, dynamic>();
    loginMap['STORE'] = storeId; //Change to storeId later
    loginMap['PASS'] = storeSecret; //Change to storeSecret later
    loginMap['type'] = 'login';

    FormData loginData = new FormData.fromMap(loginMap);

    try {
      Response response =
          await Dio().post("http://10.0.88.178/process.php", data: loginData);
      var jsonData = json.decode(response.toString());

      List<String> strings = [];
      storeName = prefs.getString('name');
      storeBalance = jsonData['balance'].toString();

      strings.add(storeName);
      strings.add(storeBalance);

      prefs.setString('balance', storeBalance);

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
              onPressed: () async { //Logout
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
                        print(snapshot);
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
              Expanded(
                child: Container(
                    margin: EdgeInsets.only(top: 40.0),
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text('How much?',
                              style: TextStyle(
                                  fontSize: 40.0, fontWeight: FontWeight.w700)),
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
                        FutureBuilder<List<Product>>(
                            future: _future,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState
                                    .waiting: //Display progress circle while loading
                                  return Expanded(
                                    child: Container(
                                      child: Center(
                                          child: SpinKitDoubleBounce(
                                        color: Theme.of(context).primaryColor,
                                        size: 50.0,
                                      )),
                                    ),
                                  );
                                default: //Display card when loaded
                                  return Expanded(
                                      child: Container(
                                          child: RefreshIndicator(
                                              key: _refreshIndicatorKey,
                                              onRefresh: _refresh,
                                              child: ListView.builder(
                                                  itemCount:
                                                      snapshot.data.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          Container(
                                                              child: Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0,
                                                                    1.25,
                                                                    0,
                                                                    1.25),
                                                            child: SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: Card(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          15.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Expanded(
                                                                            child:
                                                                                (Column(
                                                                              children: <Widget>[
                                                                                ListTile(
                                                                                    title: Text(
                                                                                      snapshot.data[index].name,
                                                                                      style: Theme.of(context).textTheme.title,
                                                                                    ),
                                                                                    subtitle: Container(
                                                                                      padding: EdgeInsets.only(top: 10.0),
                                                                                      child: Text(
                                                                                        'RM ' + FlutterMoneyFormatter(amount: snapshot.data[index].price).output.nonSymbol,
                                                                                        style: Theme.of(context).textTheme.subhead,
                                                                                      ),
                                                                                    )),
                                                                              ],
                                                                            )),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                (Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                              SizedBox(
                                                                                width: 30.0,
                                                                                child: (FlatButton(
                                                                                  child: const Text('-', style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.w200)),
                                                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      if (quantities[index] - 1 >= 0) {
                                                                                        quantities[index] -= 1;
                                                                                        totalAmount = totalAmount - snapshot.data[index].price.toInt();
                                                                                        quantitiesString[index] = quantities[index].toString();
                                                                                        _amountController.text = totalAmount.toString();
                                                                                      } else {
                                                                                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Minimum quantity is 0")));
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                )),
                                                                              ),
                                                                              Text(
                                                                                quantitiesString[index],
                                                                                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                                                                              ),
                                                                              SizedBox(
                                                                                  width: 30.0,
                                                                                  child: (FlatButton(
                                                                                    child: const Text('+', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300)),
                                                                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        quantities[index] += 1;
                                                                                        totalAmount = totalAmount + snapshot.data[index].price.toInt();
                                                                                        quantitiesString[index] = quantities[index].toString();
                                                                                        _amountController.text = totalAmount.toString();
                                                                                      });
                                                                                    },
                                                                                  ))),
                                                                            ])),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ))))));
                              }
                            }),
                      ],
                    )),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _scan(_amountController.text, quantities, productsList,
                productsNameList, context);
          },
          label: Text("Scan QR Code",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          icon: Icon(Icons.center_focus_strong)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  static Future<String> scan(BuildContext context) async { //Scan QR code
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

  void _scan(
      String _amount, quantities, products, names, BuildContext context) async { //Show dialog after scan complete
    final idList = [];
    final quantitiesList = [];
    final nameList = [];

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
                                "Product",
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.black54),
                              ),
                              Text(
                                "Quantity",
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
                            Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: nameList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            nameList[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
                                          Text(
                                            quantitiesList[index].toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
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
                                balanceMap['id'] =
                                    id;
                                balanceMap['type'] = 'checkbalance';

                                FormData balanceData =
                                new FormData.fromMap(balanceMap);


                                if (makingPayment == false) {
                                  _verifyResult =
                                      _verify(loginData, paymentData, balanceData, _amount);
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
